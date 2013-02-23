
require 'spec_helper'


describe 'sample math parser' do

  class ArithParser < Neg::Parser

    expression  == operation

    operator     == `+` | `-` | `*` | `/`
    operation    == value + (operator + value) * 0
    value        == parentheses | number
    parentheses  == `(` + expression + `)`
    number       == `-` * -1 + _('0-9') * 1
  end

  class ArithTranslator < Neg::Translator

    on(:number)    { |n| n.result.to_i }
    on(:operator)  { |n| n.result }
    on(:value)     { |n| n.results.first }

    on(:expression) { |n|
      results = n.flattened_results
      results.size == 1 ? results.first : results
    }
  end

  def parse(s, opts={})

    r = ArithParser.parse(s, opts)

    if ENV['DEBUG'] == 'true' # /!\ not $DEBUG
      puts "--#{s.inspect}-->"
      pp r
    end

    r[2]
  end

  def translate(s)

    ArithTranslator.translate(ArithParser.parse(s))
  end

  it 'parses numbers' do

    parse("0").should == true
    parse("-0").should == true
    parse("12").should == true
    parse("-3").should == true
    parse("-12").should == true
  end

  it 'parses parentheses' do

    parse("(1)").should == true
    parse("((1))").should == true
  end

  it 'parses operations' do

    parse("1+1").should == true
    parse("1+-1").should == true
  end

  it 'parses at large' do

    parse("1+(1+1)").should == true
    parse("12+(34-(56/78))").should == true
  end

  it 'translates numbers' do

    translate("0").should == 0
    translate("101").should == 101
  end

  it 'translates parentheses' do

    translate("(12)").should == 12
  end

  it 'translates operations' do

    translate("1+2+3").should == [ 1, '+', 2, '+', 3 ]
  end
end

