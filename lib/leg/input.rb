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


module Leg

  #--
  # input class
  #++

  class Input

    def initialize(s)

      @s = s
      rewind
    end

    def read(count)

      @s[@offset, count]
    end

    def skip(count)

      count.times do

        @offset = @offset + 1

        if @s[@offset, 1] == "\n"
          @line = @line + 1
          @column = 0
        else
          @column = @column + 1
        end
      end
    end

    def rewind(offset=0)

      @offset = 0
      @line = 1
      @column = 1

      skip(offset)
    end

    def position

      [ @offset, @line, @column ]
    end

    def line_and_column(join=nil)

      a = [ "line #{@line}", "column #{@column}" ]

      join ? a.join(join) : a
    end
  end
end
