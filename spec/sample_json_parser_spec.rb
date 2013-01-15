
require 'spec_helper'


describe 'sample JSON parser' do

  class JsonParser < Neg::Parser

    parser do

      json == spaces? + value + spaces?

      spaces? == _("\s\n\r") * 0

      value == object | array | string | number | btrue | bfalse | null

      object == `{` + (entry + (`,` + entry) * 0) * 0 + `}`
      entry == spaces? + string + spaces? + `:` + json

      array == `[` + (json + (`,` + json) * 0) * 0 + `]`

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

      on(:json) { |n| n.results.first }
      on(:value) { |n| n.results.first }
      on(:spaces?) { throw nil }

      on(:object) { |n|
        f2 = n.results.flatten(2)
        Hash[f2.any? ? [ f2.shift ] + f2.flatten(2) : []]
      }
      on(:array) { |n|
        f2 = n.results.flatten(2)
        f2.any? ? [ f2.shift ] + f2.flatten(2) : []
      }

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
      [ :json,
        [ 0, 1, 1 ],
        true,
        nil,
        [ [ :spaces?, [ 0, 1, 1 ], true, '', [] ],
          [ :value, [ 0, 1, 1 ], true, nil, [
            [ :bfalse, [ 0, 1, 1 ], true, 'false', [] ] ] ],
          [ :spaces?, [ 5, 1, 6 ], true, '', [] ] ] ]
  end

  it 'parses "13"' do

    JsonParser.parse("13", :translate => false).should ==
      [ :json,
        [ 0, 1, 1 ],
        true,
        nil,
        [ [ :spaces?, [ 0, 1, 1 ], true, "", [] ],
          [ :value, [ 0, 1, 1 ], true, nil, [
            [ :number, [ 0, 1, 1 ], true, "13", [] ] ] ],
          [ :spaces?, [ 2, 1, 3 ], true, "", [] ] ] ]
  end

  it 'parses "-12"' do

    JsonParser.parse("-12", :translate => false).should ==
      [ :json,
        [ 0, 1, 1 ],
        true,
        nil,
        [ [ :spaces?, [ 0, 1, 1 ], true, "", [] ],
          [ :value, [ 0, 1, 1 ], true, nil, [
            [ :number, [ 0, 1, 1 ], true, "-12", [] ] ] ],
          [ :spaces?, [ 3, 1, 4 ], true, "", [] ] ] ]
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
      JsonParser.parse("x")
    end.should raise_error(Neg::ParseError, 'expected "{", got "x"')
  end
end

