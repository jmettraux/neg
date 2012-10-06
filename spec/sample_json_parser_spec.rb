
require 'spec_helper'


describe 'sample JSON parser' do

  class JsonParser < Neg::Parser

    #rule(:comma) { spaces? >> str(',') >> spaces? }

    #rule(:array) {
    #  str('[') >> spaces? >>
    #  (value >> (comma >> value).repeat).maybe.as(:array) >>
    #  spaces? >> str(']')
    #}

    #rule(:object) {
    #  str('{') >> spaces? >>
    #  (entry >> (comma >> entry).repeat).maybe.as(:object) >>
    #  spaces? >> str('}')
    #}

    #rule(:entry) {
    #  (
    #     string.as(:key) >> spaces? >>
    #     str(':') >> spaces? >>
    #     value.as(:val)
    #  ).as(:entry)
    #}

    #rule(:attribute) { (entry | value).as(:attribute) }

    #rule(:string) {
    #  str('"') >> (
    #    #str('\\') >> any | str('"').absent? >> any
    #    #(str('\\') | str('"').absent?) >> any
    #    (str('\\') >> any | match('[^"]')
    #  ).repeat.as(:string) >> str('"')
    #}

    json == spaces? + value + spaces?

    spaces? == _(" \t") * 0

    #value == string | number | object | array | btrue | bfalse | null
    value == number | btrue | bfalse | null

    digit == _("0-9")

    number ==
      `-` * -1 +
      (`0` | (_("1-9") + digit * 0)) +
      (`.` + digit * 1) * -1 +
      (_("eE") + _("+-") * -1 + digit * 1) * -1

    btrue == `true`
    bfalse == `false`
    null == `null`
  end

  it 'flips burgers' do

    puts '-' * 80
    puts JsonParser
    puts '-' * 80
  end

  it 'parses "false"' do

    pp JsonParser.parse("false")
    JsonParser.parse("false")[2].should == true
  end

  it 'parses "13"' do

    pp JsonParser.parse("13")
    JsonParser.parse("13")[2].should == true
  end

  it 'parses "-12"' do

    pp JsonParser.parse("-12")
    JsonParser.parse("-12")[2].should == true
  end
end

