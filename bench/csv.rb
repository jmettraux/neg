
#
# This benchmark and its test data was lifted from parslet-benchmark
# https://github.com/kschiess/parslet-benchmarks
#
# The goal is to check how poorly neg performs compared to Parslet.
# It also helps determine the cost of new features.
#
# Many thanks to Kaspar Schiess.
#

require 'pp'
require 'neg'


class CsvParser < Neg::Parser

  parser do

    file         == (record + newline) * 1
    record       == field + (comma + field) * 0
    field        == escaped | non_escaped
    escaped      == dquote + (textdata | comma | cr | lf | dquote + dquote) * 0 + dquote
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

#data = File.readlines(File.expand_path('../test_data.csv', __FILE__)).first
data = File.read(File.expand_path('../test_data.csv', __FILE__))

t = Time.now
CsvParser.parse(data)
p Time.now - t

