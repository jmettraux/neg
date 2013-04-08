
require 'spec_helper'


describe 'sample JSON parser (fast thanks to regexes)' do

  class FasterJsonParser < Neg::Parser

    parser do

      value ==
        spaces? +
        (object | array | string | number | btrue | bfalse | null) +
        spaces?

      spaces? == _(/[\s\n\r]*/m)

      object == `{` + (entry + (`,` + entry) * 0) * 0 + `}`
      entry == spaces? + string + spaces? + `:` + value

      array == `[` + (value + (`,` + value) * 0) * 0 + `]`

      string == _(/^"(\\.|[^"])*"/m)

      number == _(/^-?\d+(\.\d+)?([eE][+-]?\d+)?/)

      btrue == `true`
      bfalse == `false`
      null == `null`
    end

    translator do

      on(:value) { |n| n.results.first.first }
      on(:spaces?) { throw nil }

      on(:object) { |n| Hash[n.flattened_results] }
      on(:array) { |n| n.flattened_results }

      on(:string) { |n| eval(n.result) }

      on(:number) { |n|
        n.result.match(/[\.eE]/) ? n.result.to_f : n.result.to_i
      }

      on(:btrue) { true }
      on(:bfalse) { false }
      on(:null) { nil }
    end
  end

  it 'parses "false"' do

    FasterJsonParser.parse("false", :translate => false).should ==
      [ :value,
        0,
        true,
        nil,
        [
          [ :spaces?, 0, true, '', [] ],
          [ nil, 0, true, nil, [
            [:bfalse, 0, true, 'false', [] ] ] ],
          [ :spaces?, 5, true, '', [] ] ] ]
  end

  it 'parses "13"' do

    FasterJsonParser.parse("13", :translate => false).should ==
      [ :value,
        0,
        true,
        nil,
        [
          [ :spaces?, 0, true, '', [] ],
          [ nil, 0, true, nil, [
            [:number, 0, true, '13', [] ] ] ],
          [ :spaces?, 2, true, '', [] ] ] ]
  end

  it 'parses "-12"' do

    FasterJsonParser.parse("-12", :translate => false).should ==
      [ :value,
        0,
        true,
        nil,
        [
          [ :spaces?, 0, true, '', [] ],
          [ nil, 0, true, nil, [
            [:number, 0, true, '-12', [] ] ] ],
          [ :spaces?, 3, true, '', [] ] ] ]
  end

  it 'translates "false"' do

    FasterJsonParser.parse("false").should == false
  end

  it 'translates "13"' do

    FasterJsonParser.parse("13").should == 13
  end

  it 'translates "-12"' do

    FasterJsonParser.parse("-12").should == -12
  end

  it 'translates "-1.2"' do

    FasterJsonParser.parse("-1.2").should == -1.2
  end

  it 'translates "-1.2e8"' do

    FasterJsonParser.parse("-1.2e8").should == -120000000.0
  end

  it 'translates "-1e8"' do

    FasterJsonParser.parse("-1e8").should == -100000000.0
  end

  it 'translates "null"' do

    FasterJsonParser.parse("null").should == nil
  end

  it 'translates "[]"' do

    FasterJsonParser.parse("[]").should == []
  end

  it 'translates "[ 1, 2, -3 ]"' do

    FasterJsonParser.parse("[ 1, 2, -3 ]").should == [ 1, 2, -3 ]
  end

  it 'translates "[ 1, [ true, 2, false ], -3 ]"' do

    FasterJsonParser.parse("[ 1, [ true, 2, false ], -3 ]").should ==
      [ 1, [ true, 2, false ], -3 ]
  end

  it 'translates "" (empty string)' do

    FasterJsonParser.parse('""').should == ''
  end

  it 'translates "a bc"' do

    FasterJsonParser.parse('"a bc"').should == 'a bc'
  end

  it 'translates "a \"nada\" bc"' do

    FasterJsonParser.parse('"a \"nada\" bc"').should == 'a "nada" bc'
  end

  it 'translates {} (empty object)' do

    FasterJsonParser.parse('{}').should == {}
  end

  it 'translates { "a": 1, "b": "B" }' do

    FasterJsonParser.parse('{ "a": 1, "b": "B" }').should == { 'a' => 1, 'b' => 'B' }
  end

  it 'translates { "a": [ 1, 2, "trois" ] }' do

    FasterJsonParser.parse('{ "a": [ 1, 2, "trois" ] }').should ==
      { 'a' => [ 1, 2, 'trois' ] }
  end

  it 'tolerates newlines' do

    FasterJsonParser.parse(%{
      [ 1,2
      , 3
      ]
    }).should ==
      [ 1, 2, 3 ]
  end

  it 'raises a ParseError on incorrect input' do

    lambda do
      FasterJsonParser.parse('x')
    end.should raise_error(Neg::ParseError, 'expected "null", got "x"')
  end
end

