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


module Neg

  class Translator

    def self.on(node_name, &block)

      @rules ||=
        { nil => lambda { |n| n.results.empty? ? throw(nil) : n.results } }
          #
          # the default rule for anonymous nodes...

      @rules[node_name] = block
    end

    def self.translate(parse_tree)

      results =
        parse_tree[4].each_with_object([]) { |tree, a|
          catch(nil) { a << translate(tree) } if tree[2]
        }

      apply(parse_tree, results)
    end

    def self.apply(parse_tree, results)

      rule = (@rules || {})[parse_tree[0]]

      rule ? rule.call(Node.new(parse_tree, results)) : results
    end

    class Node

      attr_reader :parse_tree, :results

      def initialize(parse_tree, results)

        @parse_tree = parse_tree
        @results = results
      end

      def position;  @parse_tree[1]; end
      def offset;    @parse_tree[1][0]; end
      def line;      @parse_tree[1][1]; end
      def column;    @parse_tree[1][2]; end

      def result;    @parse_tree[3]; end

      # Useful when the grammar has something of the form:
      #
      #   array == `[` + (value + (`,` + value) * 0) * 0 + `]`
      #
      # It flattens the value array.
      #
      # Look at the spec/sample_* files to see it in action.
      #
      def flattened_results

        f2 = results.flatten(2)
        f2.any? ? [ f2.shift ] + f2.flatten(2) : []
      end
    end
  end
end

