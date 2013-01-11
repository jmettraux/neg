
require 'spec_helper'


describe 'sample math parser' do

  class ArithParser < Neg::Parser

    expression  == operation

    operation   == value + ((`+` | `-` | `*` | `/`) + value) * 0
    value       == parenthese | number
    parenthese  == `(` + expression + `)`
    number      == `-` * -1 + _('0-9') * 1
  end

  def parse(s, opts={})

    r = ArithParser.parse(s, opts)

    if ENV['DEBUG'] == 'true' # /!\ not $DEBUG
      puts "--#{s.inspect}-->"
      pp r
    end

    r[2]
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

  it 'flips burgers' do

    parse("1+1").should == true
    #parse("1+1", :noreduce => true).should == true
  end
end

