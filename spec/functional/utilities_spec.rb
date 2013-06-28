require 'spec_helper'
require 'fakefs/safe'

describe 'utilities' do

  context '#repl?' do

    before(:each) do
      @dollar_zero = $0
    end

    after(:each) do
      $0 = @dollar_zero
    end

    def set_dollar_zero(val)
      $0 = val
    end

    it 'recognizes IRB' do
      set_dollar_zero('irb')
      repl?.should be_true
    end

    it 'recognizes Pry' do
      set_dollar_zero('pry')
      repl?.should be_true
    end

    it 'recognizes Rails Console' do
      set_dollar_zero('script/rails')
      repl?.should be_true
    end

    it 'recognizes Bundle Console' do
      set_dollar_zero('bin/bundle')
      repl?.should be_true
    end

    it 'returns false when not in a REPL' do
      set_dollar_zero(__FILE__)
      repl?.should be_false
    end
  end

  context '#safe' do

    it 'allows safe operations' do
      lambda {
        safe{ 1 + 1 }
      }.should_not raise_error(SecurityError)
    end

    it 'returns the value of the block when safe' do
      safe{ 1 + 1 }.should eq 2
    end

    it 'passes all arguments to the block' do
      safe(1, 2, 3){|x, y, z| x + y + z }.should eq 6
    end

    it 'rejects unsafe operations on tainted objects' do
      lambda {
        safe{ Signal.trap('INT'.taint) }
      }.should raise_error(SecurityError)
    end

    it 'rejects the use of #eval' do
      lambda {
        safe{ eval 'puts 1' }
      }.should raise_error(SecurityError)
    end
  end

  context '#slurp' do

    before(:all) { FakeFS.activate! }
    after(:all) { FakeFS.deactivate! }

    let!(:path){ 'slurp.txt' }
    let!(:text){ 'Hello, world!' }

    it 'returns the contents of the file' do
      File.open(path, 'w+') {|f| f.write(text) }
      slurp(path).should eq text
    end

    it 'raises an exception when the file does not exist' do
      lambda {
        slurp('path/does/not/exist')
      }.should raise_error(Errno::ENOENT)
    end
  end

  context '#slurpee' do

    before(:all) { FakeFS.activate! }
    after(:all) { FakeFS.deactivate! }

    let!(:path){ 'slurp.txt' }
    let!(:text){ 'You are number 6.' }
    let!(:erb) { 'You are number <%= 2 * 3 %>.' }

    it 'returns the processed contents of the file' do
      File.open(path, 'w+') {|f| f.write(erb) }
      slurpee(path).should eq text
    end

    it 'raises an exception when the file does not exist' do
      lambda {
        slurpee('path/does/not/exist')
      }.should raise_error(Errno::ENOENT)
    end
  end

  context '#delta' do

    it 'computes the delta of two positive values' do
      delta(10.5, 5.0).should be_within(0.01).of(5.5)
    end

    it 'computes the delta of two negative values' do
      delta(-10.5, -5.0).should be_within(0.01).of(5.5)
    end

    it 'computes the delta of a positive and negative value' do
      delta(10.5, -5.0).should be_within(0.01).of(15.5)
    end

    it 'computes the delta of two positive values with a block' do
      v1 = {:count => 10.5}
      v2 = {:count => 5.0}
      delta(v1, v2){|x| x[:count]}.should be_within(0.01).of(5.5)
    end

    it 'computes the delta of two negative values with a block' do
      v1 = {:count => -10.5}
      v2 = {:count => -5.0}
      delta(v1, v2){|x| x[:count]}.should be_within(0.01).of(5.5)
    end

    it 'computes the delta of a positive and negative value with a block' do
      v1 = {:count => 10.5}
      v2 = {:count => -5.0}
      delta(v1, v2){|x| x[:count]}.should be_within(0.01).of(15.5)
    end
  end

end
