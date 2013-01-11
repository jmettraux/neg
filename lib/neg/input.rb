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

  def self.Input(o)

    o.is_a?(Input) ? o : Input.new(o)
  end

  class Input

    def initialize(s)

      @s = s
      rewind
    end

    def read(count)

      s = ''

      count.times do

        c = @s[@offset, 1]

        break if c.nil?

        s << c

        @offset = @offset + 1

        if c == "\n"
          @line = @line + 1
          @column = 0
        else
          @column = @column + 1
        end
      end

      s
    end

    def rewind(pos=[ 0, 1, 1 ])

      @offset, @line, @column = pos
    end

    def position

      [ @offset, @line, @column ]
    end

    def eoi?

      @offset >= @s.length
    end

    def remains

      rem = read(7)

      rem.length >= 7 ? rem = rem + '...' : rem
    end
  end
end

