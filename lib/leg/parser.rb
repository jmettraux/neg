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

  class Parser

    def initialize

      @root = nil
      @non_terminals = {}
    end

    def parse(s)

      resolve_non_terminals

      result = @non_terminals[@root].parse(s)
      result[0] = @root

      result
    end

    def self.parse(s)

      self.new.parse(s)
    end

    protected

    def resolve_non_terminals

      (self.methods - Leg::Parser.instance_methods).each { |m|
        @root ||= m.to_sym
        @non_terminals[m.to_sym] = send(m)
      }
    end

    def `(s)

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
    end

    class StringParser < SubParser

      def initialize(s)

        @s = s
      end

      def parse(i)

        i = Leg::Input(i)
        start = i.position
        s = i.read(@s.length)

        if s == @s
          i.skip(@s.length)
          [ nil, true, start, @s ]
        else
          [ nil, false, start, "expected #{@s.inspect}, got #{s.inspect}" ]
        end
      end
    end

    class CompositeParser < SubParser

      def initialize(left, right)

        @children = [ left, right ]
      end
    end

    class SequenceParser < CompositeParser

      def parse(i)

        i = Leg::Input(i)
        start = i.position

        results = []

        @children.each do |c|

          results << c.parse(i)
          break unless results.last[1]
        end

        success = results.last[1]

        [ nil, success, start, results ]
      end
    end

    class AlternativeParser < CompositeParser

      def parse(i)

        i = Leg::Input(i)
        start = i.position

        results = []

        @children.each do |c|

          results << c.parse(i)
        end

        success = !! results.find { |r| r[1] }

        [ nil, success, start, results ]
      end
    end
  end
end

