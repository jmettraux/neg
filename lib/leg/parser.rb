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

    def parse(s)

      @non_terminals =
        (self.methods - Leg::Parser.instance_methods).collect { |m| self.send(m) }
      @non_terminals.first.parse(s)
    end

    protected

    def `(s)

      StringParser.new(s)
    end

    #--
    # sub parsers
    #++

    class BaseParser

      protected

      def to_input(o)

        o.is_a?(Leg::Input) ? o : Leg::Input.new(o)
      end
    end

    class StringParser < BaseParser

      def initialize(s)
        @s = s
      end

      def parse(i)
        i = to_input(i)
        s = i.read(@s.length)
        s == @s ? [ @s, i.position ] : error(ss, i)
      end

      def error(s, i)
        "expected #{@s.inspect}, got #{s.inspect} at #{i.line_and_column}"
      end
    end
  end
end

