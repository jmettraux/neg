
require 'spec_helper'


describe 'memo feature' do

  class MemoParser < Neg::Parser

    exp == num + `+` + num | num + `-` + num
    num == _('0-9') * 1
  end

  def parse(s, opts={})

    MemoParser.parse(s, opts)
  end

  it 'parses additions' do

    parse('12+34')[2].should == true
  end

  it 'parses substractions' do

    parse('12-34')[2].should == true
  end
end

