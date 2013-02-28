
require 'spec_helper'


describe 'neg and errors' do

  class BlockParser < Neg::Parser

    parser do

      blocks == nl? + block + (nl + block) * 0 + nl?

      block == sp? + `begin` + sp + _('a-z') + nl + body + sp? + `end`
      body == ((line | block) + nl) * 0
      line == sp + `line`

      nl == _("\s\n") * 1
      nl? == _("\s\n") * 0
      sp == _(" ") * 1
      sp? == _(" ") * 0
    end

    translator do
    end
  end

  it 'parses a single empty block' do

    BlockParser.parse(%{
      begin a
      end
    })
  end

  it 'parses nested blocks' do

    BlockParser.parse(%{
      begin a
        begin b
        end
      end
    })
  end

  it 'parses successive blocks' do

    BlockParser.parse(%{
      begin a
      end
      begin b
      end
    })
  end

  it 'fails gracefully on a missing end (0)' do

    err = nil

    begin
      BlockParser.parse(%{
        begin a
          begin b
        end
      })
    rescue => err
    end

    err.class.should == Neg::ParseError
    err.position.should == [ 53, 5, 6 ]
    err.message.should == 'expected "end", got ""'
  end

  it 'fails gracefully on a missing end (1)' do

    err = nil

    begin
      BlockParser.parse(%{
        begin a
        end
        begin b
          begin c
        end
      })
    rescue => err
    end

    err.class.should == Neg::ParseError
    err.position.should == [ 81, 7, 6 ]
    err.message.should == 'expected "end", got ""'
  end

  it 'fails gracefully on a li too much (2)' do

    err = nil

    begin
      BlockParser.parse(%{
        begin a
        end
        begin b
          begin c
            li
          end
        end
      })
    rescue => err
    end

    err.class.should == Neg::ParseError
    err.position.should == [ 75, 6, 12 ]
    err.message.should == 'expected "end", got "li\n"'
  end
end

