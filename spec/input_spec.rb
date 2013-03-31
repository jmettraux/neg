
require 'spec_helper'


describe Neg::Input do

  let(:input) {
    Neg::Input.new(%{
God knows, in the present quarrel of our civil war, where there are a hundred
articles to dash out and to put in, great and very considerable, how many there
are who can truly boast, they have exactly and perfectly weighed and understood
the grounds and reasons of the one and the other party; 'tis a number, if they
make any number, that would be able to give us very little disturbance. But
what becomes of all the rest, under what ensigns do they march, in what quarter
do they lie? Theirs have the same effect with other weak and ill-applied
medicines; they have only set the humours they would purge more violently in
work, stirred and exasperated by the conflict, and left them still behind. The
potion was too weak to purge, but strong enough to weaken us; so that it does
not work, but we keep it still in our bodies, and reap nothing from the
operation but intestine gripes and dolours.

So it is, nevertheless, that Fortune still reserving her authority in defiance
of whatever we are able to do or say, sometimes presents us with a necessity
so urgent, that 'tis requisite the laws should a little yield and give way;
and when one opposes the increase of an innovation that thus intrudes itself
by violence, to keep a man's self in so doing, in all places and in all things
within bounds and rules against those who have the power, and to whom all
things are lawful that may in any way serve to advance their design, who have
no other law nor rule but what serves best to their own purpose, 'tis a
dangerous obligation and an intolerable inequality
    })
  }

  describe '#position' do

    it 'returns [ 0, 1, 1 ] at offset 0' do

      input.position.should == [ 0, 1, 1 ]
    end

    it 'returns the correct [ offset, line, column ] at offset 1' do

      input.rewind(1)
      input.position.should == [ 1, 2, 1 ]
    end

    it 'returns the correct [ offset, line, column ]' do

      input.rewind(5)
      input.position.should == [ 5, 2, 5 ]
    end

    it 'returns the correct [ offset, line, column ] at the last offset' do

      input.rewind(input.instance_variable_get(:@s).string.length - 1)
      input.position.should == [ 1564, 24, 4 ]
    end
  end

  describe '#remaining' do

    it 'returns the string starting at the current offset' do

      input.remaining.should == "\nGod kn..."
    end
  end
end

