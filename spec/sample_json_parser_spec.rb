
require 'spec_helper'


describe 'sample JSON parser' do

  class JsonParser < Neg::Parser

    parser do

      value ==
        spaces? +
        (object | array | string | number | btrue | bfalse | null) +
        spaces?

      spaces? == _("\s\n\r") * 0

      object == `{` + (entry + (`,` + entry) * 0) * 0 + `}`
      entry == spaces? + string + spaces? + `:` + value

      array == `[` + (value + (`,` + value) * 0) * 0 + `]`

      string == `"` + ((`\\` + _) | _('^"')) * 0 + `"`

      _digit == _("0-9")

      number ==
        `-` * -1 +
        (`0` | (_("1-9") + _digit * 0)) +
        (`.` + _digit * 1) * -1 +
        (_("eE") + _("+-") * -1 + _digit * 1) * -1

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

    JsonParser.parse("false", :translate => false).should ==
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

    JsonParser.parse("13", :translate => false).should ==
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

    JsonParser.parse("-12", :translate => false).should ==
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

    JsonParser.parse("false").should == false
  end

  it 'translates "13"' do

    JsonParser.parse("13").should == 13
  end

  it 'translates "-12"' do

    JsonParser.parse("-12").should == -12
  end

  it 'translates "-1.2"' do

    JsonParser.parse("-1.2").should == -1.2
  end

  it 'translates "-1.2e8"' do

    JsonParser.parse("-1.2e8").should == -120000000.0
  end

  it 'translates "-1e8"' do

    JsonParser.parse("-1e8").should == -100000000.0
  end

  it 'translates "null"' do

    JsonParser.parse("null").should == nil
  end

  it 'translates "[]"' do

    JsonParser.parse("[]").should == []
  end

  it 'translates "[ 1, 2, -3 ]"' do

    JsonParser.parse("[ 1, 2, -3 ]").should == [ 1, 2, -3 ]
  end

  it 'translates "[ 1, [ true, 2, false ], -3 ]"' do

    JsonParser.parse("[ 1, [ true, 2, false ], -3 ]").should ==
      [ 1, [ true, 2, false ], -3 ]
  end

  it 'translates "" (empty string)' do

    JsonParser.parse('""').should == ''
  end

  it 'translates "a bc"' do

    JsonParser.parse('"a bc"').should == 'a bc'
  end

  it 'translates "a \"nada\" bc"' do

    JsonParser.parse('"a \"nada\" bc"').should == 'a "nada" bc'
  end

  it 'translates {} (empty object)' do

    JsonParser.parse('{}').should == {}
  end

  it 'translates { "a": 1, "b": "B" }' do

    JsonParser.parse('{ "a": 1, "b": "B" }').should == { 'a' => 1, 'b' => 'B' }
  end

  it 'translates { "a": [ 1, 2, "trois" ] }' do

    JsonParser.parse('{ "a": [ 1, 2, "trois" ] }').should ==
      { 'a' => [ 1, 2, 'trois' ] }
  end

  it 'tolerates newlines' do

    JsonParser.parse(%{
      [ 1,2
      , 3
      ]
    }).should ==
      [ 1, 2, 3 ]
  end

  it 'raises a ParseError on incorrect input' do

    lambda do
      JsonParser.parse('x')
    end.should raise_error(Neg::ParseError, 'expected "null", got "x"')
  end
end

