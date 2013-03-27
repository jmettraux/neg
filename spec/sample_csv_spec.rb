
require 'spec_helper'


describe 'sample csv parser' do

  #
  # This parser is based on the CSV parser written by Kaspar Schiess
  # in
  #
  #   https://github.com/kschiess/parslet-benchmarks
  #
  class CsvParser < Neg::Parser

    parser do

      file         == (record + newline) * 1
      record       == field + (comma + field) * 0
      field        == escaped | non_escaped
      escaped      == dquote +
                      (textdata | comma | cr | lf | dquote + dquote) * 0 +
                      dquote
      non_escaped  == textdata * 0
      textdata     == (- (comma | dquote | cr | lf) + _) * 1
      newline      == lf + cr * -1
      lf           == `\n`
      cr           == `\r`
      dquote       == `"`
      comma        == `,`
    end

    translator do

      on(:file)         { |n| n.results.collect(&:flatten) }
      on(:record)       { |n| n.flattened_results }
      on(:escaped)      { |n| n.results.join }
      on(:non_escaped)  { |n| n.results.join }
      on(:textdata)     { |n| n.result }
      on(:newline)      { |n| throw nil }
    end
  end

  it 'parses' do

    data =
      CsvParser.parse(
        File.read(File.expand_path('../sample_csv_data.txt', __FILE__)))

    data[1][2].should == 'The Electric Marketing Co. LLC'
  end
end

