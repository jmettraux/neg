
require 'spec_helper'


describe 'sample math parser' do

  class ArithParser < Neg::Parser

    expression  == operation

    operation   == value + ((`+` | `-` | `*` | `/`) + value) * 0
    value       == parenthese | number
    parenthese  == `(` + expression + `)`
    number      == `-` * -1 + _('0-9') * 1
  end

  class ArithTranslator < Neg::Translator

    on :number do |n| n.result.to_i; end
    on :value do |n| n.results.first; end
    #on :parenthese do |n| p [ :par, n ]; nil; end
    #on :operation do |n| p [ :op, n ]; nil; end

    on :expression do |n|
      n.results.last.empty? ? n.results.first : n.results
    end
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
  end
end

