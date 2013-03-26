#--
# Copyright (c) 2012-2013, John Mettraux, jmettraux@gmail.com
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

require 'neg/input'
require 'neg/errors'
require 'neg/translator'


module Neg

  class Parser

    def self.`(s)      ; StringParser.new(s); end
    def self._(c=nil)  ; CharacterParser.new(c); end

    def self.parser(&block)

      self.instance_eval(&block)
    end

    def self.translator(&block)

      @translator = Class.new(Neg::Translator)
      @translator.instance_eval(&block)
    end

    def self.method_missing(m, *args)

      return super if args.any?
      return super if m.to_s == 'to_ary'

      @root ||= m
      pa = NonTerminalParser.new(m)

      (class << self; self; end).__send__(:define_method, m) { pa }

      pa
    end

    def self.reduce(result)

      if result[0] && result[2] && result[3]
        result[4] =
          []
      else
        result[4] =
          result[4].each_with_object([]) { |cr, a| a << reduce(cr) if cr[2] }
      end

      result
    end

    def self.parse(s, opts={})

      i = Neg::Input(s)

      result = __send__(@root).parse(i, opts)

      result[2] = false if result[2] && ( ! i.eoi?)

      if @translator && opts[:translate] != false
        if result[2]
          @translator.translate(result)
        else
          raise ParseError.new(result)
        end
      elsif result[2] == false || opts[:noreduce]
        result
      else
        reduce(result)
      end
    end

    def self.to_s

      s = [ "#{name}:" ]

      methods.sort.each do |mname|

        m = method(mname)

        next if m.owner == Class
        next if %w[ _ to_s parser translator ].include?(mname.to_s)
        next unless m.arity == (RUBY_VERSION > '1.9' ? 0 : -1)
        next unless m.owner.ancestors.include?(Class)
        next unless m.receiver.ancestors.include?(Neg::Parser)

        seen = []

        s << "  #{__send__(mname).to_s(seen, nil)}"
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

      def parse(input_or_string, opts)

        input = Neg::Input(input_or_string)
        start = input.position

        success, result, children = do_parse(input, opts)

        input.rewind(start) unless success

        [ @name, start, success, result, children ]
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

      def refine(children_results)

        children_results.collect { |cr|
          if cr[0] && cr[0].to_s.match(/^_/).nil?
            false
          elsif cr[2]
            cr[3] ? cr[3] : refine(cr[4])
          else
            nil
          end
        }.flatten.compact
      end

      def do_parse(i, opts)

        raise ParserError.new("\"#{@name}\" is missing") if @child.nil?

        r = @child.do_parse(i, opts)

        return r if r[0] == false
        return r if r[1].is_a?(String)

        report = refine(r[2])
        report = report.include?(false) ? nil : report.join

        [ true, report, r[2] ]
      end

      def parse(input_or_string, opts)

        input = Neg::Input(input_or_string)

        if memo = input.get_memo(@name)

          input.rewind(memo.end)

          memo.result

        else

          r = super(input, opts)

          input.set_memo(r)
        end
      end

      def to_s(seen=[], parent=nil)

        return @name if seen.include?(@name)
        seen << @name

        child = @child ? @child.to_s(seen, self) : '<missing>'

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

      def do_parse(i, opts)

        rs = []

        loop do
          rs << @child.parse(i, opts)
          break if rs.last[2] == false
        end

        rs.size.downto(1) do |i|

          r = rs[i - 1]

          next if r[2] == false

          if @max && i > @max
            r[2] = false
            r[3] = "did not expect #{r[3].inspect} (min #{@min} max #{@max})"
          end
        end

        trs = rs.take_while { |r| r[2] == true }
        rs = trs + [ rs.find { |r| r[2] == false } ]

        success = trs.size >= @min && (@max.nil? || trs.size <= @max)

        i.rewind(rs.last[1]) if success && rs.last[2] == false

        [ success, nil, rs ]
      end

      def to_s(seen=[], parent=nil)

        "#{@child.to_s(seen, self)} * #{@range.inspect}"
      end
    end

    class StringParser < SubParser

      def initialize(s)

        @s = s
      end

      def do_parse(i, opts)

        if (s = i.read(@s.length)) == @s
          [ true, @s, [] ]
        else
          [ false, "expected #{@s.inspect}, got #{s.inspect}", [] ]
        end
      end

      def to_s(seen=[], parent=nil)

        "`#{@s}`"
      end
    end

    class CharacterParser < SubParser

      def initialize(c)

        @c = c
        @r = Regexp.new(c ? "[#{c}]" : '.')
      end

      def do_parse(i, opts)

        if (s = i.read(1)).match(@r)
          [ true, s, [] ]
        else
          [ false, "#{s.inspect} doesn't match #{@c.inspect}", [] ]
        end
      end

      def to_s(seen=[], parent=nil)

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

      def do_parse(i, opts)

        results = []

        @children.each do |c|

          results << c.parse(i, opts)
          break unless results.last[2]
        end

        [ results.last[2], nil, results ]
      end

      def to_s(seen=[], parent=nil)

        "(#{@children.collect { |c| c.to_s(seen, self) }.join(' + ')})"
      end
    end

    class AlternativeParser < CompositeParser

      def |(pa)

        @children << pa

        self
      end

      def do_parse(i, opts)

        results = []

        @children.each { |c|
          results << c.parse(i, opts)
          break if results.last[2]
        }

        results = results[-1, 1] if results.last[2] && ! opts[:noreduce]

        [ results.last[2], nil, results ]
      end

      def to_s(seen=[], parent=nil)

        "(#{@children.collect { |c| c.to_s(seen, self) }.join(' | ')})"
      end
    end

    class LookaheadParser < SubParser

      def initialize(child, presence)

        @child = child
        @presence = presence
      end

      def do_parse(i, opts)

        start = i.position

        r = @child.parse(i, opts)
        i.rewind(start)

        success = r[2]
        success = ! success if ! @presence

        result = if success
          '' # for NonTerminal#reduce not to continue
        else
          [
            @child.to_s, 'is not', @presence ? 'present' : 'absent'
          ].join(' ')
        end

        [ success, result, [ r ] ]
      end

      def to_s(seen=[], parent=nil)

        "#{@presence ? '~' : '-'}#{@child.to_s(seen, self)}"
      end
    end
  end
end

