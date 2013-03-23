
require 'spec_helper'


describe 'memo feature' do

  class MemoParser < Neg::Parser

    exp == num + `+` + num | num + `-` + num
    num == _('0-9') * 1
  end

  def parse(s, opts={})

    i = Neg::Input(s)

    r = MemoParser.parse(i, opts)

    [ i, r ]
  end

  it 'parses additions' do

    i, r = parse('12+34')

    r[2].should ==
      true
    i.instance_variable_get(:@memos).keys.sort.should == %w[ exp@0 num@0 num@3 ]
  end

  it 'parses substractions' do

    i, r = parse('12-34')

    r[2].should ==
      true
    i.instance_variable_get(:@memos).keys.sort.should == %w[ exp@0 num@0 num@3 ]
  end
end

