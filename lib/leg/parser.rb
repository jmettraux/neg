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

require 'leg/version'
require 'leg/input'


module Leg

  class UnconsumedInputError < StandardError; end

  class Parser

    def self.method_missing(m, *args)

      return super if args.any?
      return super if m.to_s == 'to_ary'

      @root ||= m
      pa = NonTerminalParser.new(m)

      (class << self; self; end).send(:define_method, m) { pa }

      pa
    end

    def self.parse(s)

      i = Leg::Input(s)

      result = send(@root).parse(i)

      if result[1] && ( ! i.eoi?)
        rem = i.read(7)
        rem = rem + '...' if rem.length >= 7
        raise UnconsumedInputError.new("remaining: #{rem.inspect}")
      end

      result
    end

    def self.`(s)

      StringParser.new(s)
    end

    #--
    # sub parsers
    #++

    class SubParser

      def +(pa)

        SequenceParser.new(self, pa)
      end

      def |(pa)

        AlternativeParser.new(self, pa)
      end

      def parse(input_or_string)

        input = Leg::Input(input_or_string)
        start = input.position

        success, result = do_parse(input)

        [ nil, success, start, result ]
      end
    end

    class NonTerminalParser < SubParser

      def initialize(name)

        @name = name
        @child = nil
      end

      def ==(pa)

        @child = pa
      end

      def do_parse(i)

        @child.do_parse(i)
      end

      def parse(input_or_string)

        r = super(input_or_string)
        r[0] = @name

        r
      end

      def to_s

        "#{@name} == #{@child.to_s}"
      end
    end

    class StringParser < SubParser

      def initialize(s)

        @s = s
      end

      def do_parse(i)

        s = i.read(@s.length)

        if s == @s
          i.skip(@s.length)
          [ true, @s ]
        else
          [ false, "expected #{@s.inspect}, got #{s.inspect}" ]
        end
      end

      def to_s

        "`#{@s}`"
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
          break unless results.last[1]
        end

        [ results.last[1], results ]
      end

      def to_s

        "(#{@children.collect(&:to_s).join(' + ')})"
      end
    end

    class AlternativeParser < CompositeParser

      def |(pa)

        @children << pa

        self
      end

      def do_parse(i)

        results = @children.collect { |c| c.parse(i) }

        [ !!results.find { |r| r[1] }, results ]
      end

      def to_s

        "(#{@children.collect(&:to_s).join(' | ')})"
      end
    end
  end
end

