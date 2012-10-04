#--
# Copyright (c) 2012-2012, John Mettraux, jmettraux@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++

require 'neg/version'
require 'neg/input'


module Neg

  class UnconsumedInputError < StandardError; end
  class ParseError < StandardError; end

  class Parser

    def self.`(s)      ; StringParser.new(s); end
    def self._(c=nil)  ; CharacterParser.new(c); end

    def self.method_missing(m, *args)

      return super if args.any?
      return super if m.to_s == 'to_ary'

      @root ||= m
      pa = NonTerminalParser.new(m)

      (class << self; self; end).send(:define_method, m) { pa }

      pa
    end

    def self.parse(s)

      i = Neg::Input(s)

      result = send(@root).parse(i)

      raise UnconsumedInputError.new(
        "remaining: #{i.remains.inspect}"
      ) if result[2] && ( ! i.eoi?)

      result
    end

    def self.to_s

      s = [ "#{name}:" ]

      methods.sort.each do |mname|

        m = method(mname)

        next if m.owner == Class
        next if %w[ _ to_s ].include?(mname.to_s)
        next unless m.arity == (RUBY_VERSION > '1.9' ? 0 : -1)
        next unless m.owner.ancestors.include?(Class)
        next unless m.receiver.ancestors.include?(Neg::Parser)

        s << "  #{send(mname).to_s}"
      end

      s << "  root: #{@root}"

      s.join("\n")
    end

    #--
    # sub parsers
    #++

    class SubParser

      def +(pa)     ; SequenceParser.new(self, pa); end
      def |(pa)     ; AlternativeParser.new(self, pa); end
      def [](name)  ; NonTerminalParser.new(name.to_s, self); end
      def *(range)  ; RepetitionParser.new(self, range); end
      def ~         ; LookaheadParser.new(self, true); end
      def -@        ; LookaheadParser.new(self, false); end

      def parse(input_or_string)

        input = Neg::Input(input_or_string)
        start = input.position

        success, result, children = do_parse(input)

        input.rewind(start) unless success

        [ nil, start, success, result, children ]
      end
    end

    class NonTerminalParser < SubParser

      def initialize(name, child=nil)

        @name = name
        @child = child
      end

      def ==(pa)

        @child = pa
      end

      def do_parse(i)

        raise ParseError.new("\"#{@name}\" is missing") if @child.nil?

        @child.do_parse(i)
      end

      def parse(input_or_string)

        r = super(input_or_string)
        r[0] = @name

        r
      end

      def to_s(parent=nil)

        child = @child ? @child.to_s(self) : '<missing>'

        if @name.is_a?(String)
          "#{child}[#{@name.inspect}]"
        elsif parent
          @name.to_s
        else #if @name.is_a?(Symbol)
          "#{@name} == #{child}"
        end
      end
    end

    class RepetitionParser < SubParser

      def initialize(child, range)

        @range = range
        @child = child

        @min, @max = case range
          when -1 then [ 0, 1 ]
          when Array then range
          else [ range, nil ]
        end
      end

      def do_parse(i)

        rs = []

        loop do
          r = @child.parse(i)
          break if ! r[2] && rs.size >= @min && (@max.nil? || rs.size <= @max)
          rs << r
          break if ! r[2]
          break if rs.size == @max
        end

        success = (rs.empty? || rs.last[2]) && (rs.size >= @min)

        [ success, nil, rs ]
      end

      def to_s(parent=nil)

        "#{@child.to_s(self)} * #{@range.inspect}"
      end
    end

    class StringParser < SubParser

      def initialize(s)

        @s = s
      end

      def do_parse(i)

        if (s = i.read(@s.length)) == @s
          [ true, @s, [] ]
        else
          [ false, "expected #{@s.inspect}, got #{s.inspect}", [] ]
        end
      end

      def to_s(parent=nil)

        "`#{@s}`"
      end
    end

    class CharacterParser < SubParser

      def initialize(c)

        @c = c
        @r = Regexp.new(c ? "[#{c}]" : '.')
      end

      def do_parse(i)

        if (s = i.read(1)).match(@r)
          [ true, s, [] ]
        else
          [ false, "#{s.inspect} doesn't match #{@c.inspect}", [] ]
        end
      end

      def to_s(parent=nil)

        @c ? "_(#{@c.inspect})" : '_'
      end
    end

    class CompositeParser < SubParser

      def initialize(left, right)

        @children = [ left, right ]
      end
    end

    class SequenceParser < CompositeParser

      def +(pa)

        @children << pa

        self
      end

      def do_parse(i)

        results = []

        @children.each do |c|

          results << c.parse(i)
          break unless results.last[2]
        end

        [ results.last[2], nil, results ]
      end

      def to_s(parent=nil)

        "(#{@children.collect { |c| c.to_s(self) }.join(' + ')})"
      end
    end

    class AlternativeParser < CompositeParser

      def |(pa)

        @children << pa

        self
      end

      def do_parse(i)

        results = []

        @children.each { |c|
          results << c.parse(i)
          break if results.last[2]
        }

        [ results.last[2], nil, results ]
      end

      def to_s(parent=nil)

        "(#{@children.collect { |c| c.to_s(self) }.join(' | ')})"
      end
    end

    class LookaheadParser < SubParser

      def initialize(child, presence)

        @child = child
        @presence = presence
      end

      def do_parse(i)

        start = i.position

        r = @child.parse(i)
        i.rewind(start)

        success = r[2]
        success = ! success if ! @presence

        result = if success
          nil
        else
          [
            @child.to_s(nil), 'is not', @presence ? 'present' : 'absent'
          ].join(' ')
        end

        [ success, result, [ r ] ]
      end

      def to_s(parent=nil)

        "#{@presence ? '~' : '-'}#{@child.to_s(self)}"
      end
    end
  end
end

