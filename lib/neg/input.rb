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

      @s = StringScanner.new(s)
      @memos = {}
      @lines = nil
    end

    def nextch

      @s.peek(1)
    end

    def scan_string(s)

      if (ss = @s.peek(s.length)) == s
        @s.pos = @s.pos + s.length
        true
      else
        ss
      end
    end

    def scan_regex(r)

      s = @s.scan(r)

      s ? s : false
    end

    def rewind(pos=0)

      @s.pos = pos
    end

    def offset

      @s.pos
    end

    def eoi?

      @s.eos?
    end

    def remaining(n=7)

      s = @s.peek(n)

      s.length < n ? s : s + '...'
    end

    def position(off=@s.pos)

      @lines ||= find_lines

      i = @lines.length / 2
      j = i
      loop do
        break if off > @lines[i] && off <= @lines[i + 1]
        j = j / 2; j = 1 if j < 1
        i += j * (off > @lines[i] ? 1 : -1)
      end

      [ off, i + 1, off - @lines[i] ]
    end

    MemoEntry = Struct.new(:result, :end)

    def get_memo(key)

      @memos["#{key}@#{@s.pos}"]
    end

    def set_memo(result)

      @memos["#{result[0]}@#{result[1]}"] = MemoEntry.new(result, @s.pos)

      result
    end

    protected

    def find_lines

      a = [ -1 ]

      current = @s.pos
      @s.pos = 0

      while @s.scan_until(/\n/)
        a << @s.pos - 1
      end
      a << @s.string.length

      @s.pos = current

      a
    end
  end
end

