
require 'spec_helper'


describe Neg::Parser::LookaheadParser do

  context '~x (presence)' do

    let(:parser) {
      Class.new(Neg::Parser) do
        root == x + y
        x == `x` + ~`y`
        y == `y`
      end
    }

    it 'parses' do

      parser.parse('xy').should ==
        [ :root,
          true,
          [ 0, 1, 1 ],
          [ [ :x,
              true,
              [ 0, 1, 1 ],
              [ [ nil, true, [ 0, 1, 1 ], "x" ],
                [ nil, true, [ 1, 1, 2 ], "`y` is present" ] ] ],
            [ :y, true, [ 1, 1, 2 ], "y" ] ] ]
    end

    it 'fails gracefully' do

      parser.parse('xx').should ==
        [ :root,
          false,
          [ 0, 1, 1 ],
          [ [ :x,
              false,
              [ 0, 1, 1 ],
              [ [ nil, true, [ 0, 1, 1 ], "x" ],
                [ nil, false, [ 1, 1, 2 ], "`y` is not present" ] ] ] ] ]
    end

    it 'is rendered correctly via #to_s' do

      parser.to_s.strip.should == %q{
:
  root == (x + y)
  x == (`x` + ~`y`)
  y == `y`
  root: root
      }.strip
    end
  end

  context '!x (absence)' do

    let(:parser) {
      Class.new(Neg::Parser) do
        root == x + z
        x == `x` + !`y`
        z == `z`
      end
    }

    it 'parses' do

      parser.parse('xz').should ==
        [ :root,
          true,
          [ 0, 1, 1 ],
          [ [ :x,
              true,
              [ 0, 1, 1 ],
              [ [ nil, true, [ 0, 1, 1 ], "x" ],
                [ nil, true, [ 1, 1, 2 ], "`y` is absent" ] ] ],
            [ :z, true, [ 1, 1, 2 ], "z" ] ] ]
    end

    it 'fails gracefully' do

      parser.parse('xy').should ==
        [ :root,
          false,
          [ 0, 1, 1 ],
          [ [ :x,
              false,
              [ 0, 1, 1],
              [ [ nil, true, [ 0, 1, 1 ], "x" ],
                [ nil, false, [ 1, 1, 2 ], "`y` is not absent" ] ] ] ] ]
    end

    it 'is rendered correctly via #to_s' do

      parser.to_s.strip.should == %q{
:
  root == (x + z)
  x == (`x` + !`y`)
  z == `z`
  root: root
      }.strip
    end
  end
end

