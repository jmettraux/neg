
require 'spec_helper'


describe Neg::Parser::LookaheadParser do

  context '~x (presence)' do

    let(:parser) {
      Class.new(Neg::Parser) do
        root == x + z
        x == `x` + ~`z`
        z == `z`
      end
    }

    it 'parses' do

      parser.parse('xz').should ==
        [ :root,
          [ 0, 1, 1 ],
          true,
          nil,
          [ [ :x, [ 0, 1, 1 ], true, 'x', [] ],
            [ :z, [ 1, 1, 2 ], true, 'z', [] ] ] ]
    end

    it 'parses (:noreduce => true)' do

      parser.parse('xz', :noreduce => true).should ==
        [ :root,
          [ 0, 1, 1 ],
          true,
          nil,
          [ [ :x,
              [ 0, 1, 1 ],
              true,
              'x',
              [ [ nil, [ 0, 1, 1 ], true, 'x', [] ],
                [ nil, [ 1, 1, 2 ], true, nil, [
                  [ nil, [ 1, 1, 2 ], true, 'z', [] ] ] ] ] ],
            [ :z, [ 1, 1, 2 ], true, 'z', [] ] ] ]
    end

    it 'fails gracefully' do

      parser.parse('xx').should ==
        [:root,
         [0, 1, 1],
         false,
         nil,
         [[:x,
           [0, 1, 1],
           false,
           nil,
           [[nil, [0, 1, 1], true, "x", []],
            [nil,
             [1, 1, 2],
             false,
             "`z` is not present",
             [[nil, [1, 1, 2], false, "expected \"z\", got \"x\"", []]]]]]]]
    end

    it 'is rendered correctly via #to_s' do

      parser.to_s.strip.should == %q{
:
  root == (x + z)
  x == (`x` + ~`z`)
  z == `z`
  root: root
      }.strip
    end
  end

  context '-x (absence)' do

    let(:parser) {
      Class.new(Neg::Parser) do
        root == x + z
        x == `x` + -`y`
        z == `z`
      end
    }

    it 'parses' do

      parser.parse('xz').should ==
        [ :root,
          [ 0, 1, 1 ],
          true,
          nil,
          [ [ :x, [ 0, 1, 1 ], true, 'x', [] ],
            [ :z, [ 1, 1, 2 ], true, 'z', [] ] ] ]
    end

    it 'fails gracefully' do

      parser.parse('xy').should ==
        [:root,
         [0, 1, 1],
         false,
         nil,
         [[:x,
           [0, 1, 1],
           false,
           nil,
           [[nil, [0, 1, 1], true, "x", []],
            [nil,
             [1, 1, 2],
             false,
             "`y` is not absent",
             [[nil, [1, 1, 2], true, "y", []]]]]]]]
    end

    it 'is rendered correctly via #to_s' do

      parser.to_s.strip.should == %q{
:
  root == (x + z)
  x == (`x` + -`y`)
  z == `z`
  root: root
      }.strip
    end
  end
end

