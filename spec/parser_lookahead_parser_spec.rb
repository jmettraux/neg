
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
          [ 0, 1, 1 ],
          true,
          [ [ :x,
              [ 0, 1, 1 ],
              true,
              [ [ nil, [ 0, 1, 1 ], true, "x" ],
                [ nil, [ 1, 1, 2 ], true, "`y` is present" ] ] ],
            [ :y, [ 1, 1, 2 ], true, "y" ] ] ]
    end

    it 'fails gracefully' do

      parser.parse('xx').should ==
        [ :root,
          [ 0, 1, 1 ],
          false,
          [ [ :x,
              [ 0, 1, 1 ],
              false,
              [ [ nil, [ 0, 1, 1 ], true, "x" ],
                [ nil, [ 1, 1, 2 ], false, "`y` is not present" ] ] ] ] ]
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
          [ 0, 1, 1 ],
          true,
          [ [ :x,
              [ 0, 1, 1 ],
              true,
              [ [ nil, [ 0, 1, 1 ], true, "x" ],
                [ nil, [ 1, 1, 2 ], true, "`y` is absent" ] ] ],
            [ :z, [ 1, 1, 2 ], true, "z" ] ] ]
    end

    it 'fails gracefully' do

      parser.parse('xy').should ==
        [ :root,
          [ 0, 1, 1 ],
          false,
          [ [ :x,
              [ 0, 1, 1],
              false,
              [ [ nil, [ 0, 1, 1 ], true, "x" ],
                [ nil, [ 1, 1, 2 ], false, "`y` is not absent" ] ] ] ] ]
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

