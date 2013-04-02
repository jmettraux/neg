
require 'pp'
require 'neg'

json = File.read(File.expand_path('../test_data.json', __FILE__))

#
# eval
#

puts 'eval'
3.times do
  t = Time.now
  a = eval(json)
  if a.size != 10_002 || a[1] != 0.533427777943 || a[0] != 'kilroy was here'
    raise "parse failed"
  end
  p Time.now - t
end


#
# stdlib's json
#

require 'json'

p JSON
3.times do
  t = Time.now
  a = JSON.parse(json)
  if a.size != 10_002 || a[1] != 0.533427777943 || a[0] != 'kilroy was here'
    raise "parse failed"
  end
  p Time.now - t
end


#
# vanilla neg parser
#

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


#
# "faster" neg parser, use regular expressions
#

puts JsonParser.name
3.times do
  t = Time.now
  a = JsonParser.parse(json)
  if a.size != 10_002 || a[1] != 0.533427777943 || a[0] != 'kilroy was here'
    raise "parse failed"
  end
  p Time.now - t
end

class JsonRegParser < Neg::Parser

  parser do

    value ==
      spaces? +
      (object | array | string | number | btrue | bfalse | null) +
      spaces?

    #spaces? == _("\s\n\r") * 0
    spaces? == _(/[\s\n\r]*/m)

    object == `{` + (entry + (`,` + entry) * 0) * 0 + `}`
    entry == spaces? + string + spaces? + `:` + value

    array == `[` + (value + (`,` + value) * 0) * 0 + `]`

    #string == `"` + ((`\\` + _) | _('^"')) * 0 + `"`
    string == _(/^"(\\.|[^"])*"/m)

    #_digit == _("0-9")
    #number ==
    #  `-` * -1 +
    #  (`0` | (_("1-9") + _digit * 0)) +
    #  (`.` + _digit * 1) * -1 +
    #  (_("eE") + _("+-") * -1 + _digit * 1) * -1
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

puts JsonRegParser.name
3.times do
  t = Time.now
  a = JsonRegParser.parse(json)
  if a.size != 10_002 || a[1] != 0.533427777943 || a[0] != 'kilroy was here'
    raise "parse failed"
  end
  p Time.now - t
end

