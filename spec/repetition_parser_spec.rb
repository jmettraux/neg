
require 'spec_helper'


describe Leg::Parser::RepetitionParser do

  class RepParser < Leg::Parser
    text == `x` ^ [ 3, 3 ]
  end

  it 'parses' do

    RepParser.parse('xxx').should ==
      [ :text, true, [ 0, 1, 1 ], [
        [ nil, true, [ 0, 1, 1 ], 'x' ],
        [ nil, true, [ 1, 1, 2 ], 'x' ],
        [ nil, true, [ 2, 1, 3 ], 'x' ] ] ]
  end

  it 'fails gracefully' do

    RepParser.parse('xx').should ==
      [ :text, false, [ 0, 1, 1 ], [
        [ nil, true, [ 0, 1, 1 ], 'x' ],
        [ nil, true, [ 1, 1, 2 ], 'x' ],
        [ nil, false, [ 2, 1, 3 ], 'expected "x", got ""' ] ] ]
  end

  it 'fails gracefully (unconsumed input)' do

    lambda {
      RepParser.parse('xxxx')
    }.should raise_error(Leg::UnconsumedInputError, 'remaining: "x"')
  end
end

