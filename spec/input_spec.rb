
require 'spec_helper'


describe Neg::Input do

  before(:each) do

    @input = Neg::Input.new("the quick blue fox\n jumped the shark\n")
  end

  it 'starts at zero' do

    @input.position.should == [ 0, 1, 1 ]
  end

  describe '#scan_string' do

    it "reads and moves" do

      @input.scan_string('the q').should == true

      @input.position.should == [ 5, 1, 6 ]
    end

    it "reads and moves (same line)" do

      @input.scan_string('the quick').should == true

      @input.position.should == [ 9, 1, 10 ]
    end

    it "reads and moves (new line)" do

      @input.scan_string("the quick blue fox\n j").should == true

      @input.position.should == [ 21, 2, 2 ]
    end
  end

  describe '#scan_regex' do
  end

  describe '#rewind' do

    it 'rewinds' do

      @input.scan_string('the quick blue fox')
      @input.rewind

      @input.position.should == [ 0, 1, 1 ]
    end

    it 'rewinds with a [ off, line, col ]' do

      @input.scan_string('the quick blue fox')
      @input.rewind([ 5, 1, 6 ])

      @input.scan_regex(/.{4}/).should == 'uick'
    end
  end

  describe '#eoi?' do

    it 'returns false if the end of input has not yet been reached' do

      @input.eoi?.should == false
    end

    it 'returns true if the end of input has been reached' do

      @input.scan_regex(/.+\n.+\n/m)

      @input.eoi?.should == true
    end
  end
end

