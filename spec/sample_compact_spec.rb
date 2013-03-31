
require 'spec_helper'


describe 'sample compact arith parser' do

  class CompactArithParser < Neg::Parser

    parser do

      expression  == operation

      operator     == `+` | `-` | `*` | `/`
      operation    == value + (operator + value) * 0
      value        == parentheses | number
      parentheses  == `(` + expression + `)`
      number       == `-` * -1 + _('0-9') * 1
    end

    translator do

      on(:number)    { |n| n.result.to_i }
      on(:operator)  { |n| n.result }
      on(:value)     { |n| n.results.first }

      on(:expression) { |n|
        results = n.results.flatten(2)
        results.size == 1 ? results.first : results
      }
    end
  end

  it 'parses and translates' do

    CompactArithParser.parse('0').should == 0
    CompactArithParser.parse('101').should == 101
    CompactArithParser.parse('(12)').should == 12
    CompactArithParser.parse('1+2+3').should == [ 1, '+', 2, '+', 3 ]
  end

  it 'does not translate if :translate => false' do

    CompactArithParser.parse('0', :translate => false).should ==
      [ :expression, 0, true, nil, [
        [ :value, 0, true, nil, [
          [ :number, 0, true, '0', [] ] ] ],
        [ nil, 1, true, nil, [] ] ] ]
  end
end

