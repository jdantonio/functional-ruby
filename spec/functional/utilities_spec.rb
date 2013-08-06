require 'spec_helper'
require 'fakefs/safe'
require 'rbconfig'

describe 'utilities' do

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

  context '#repeatedly' do

    it 'returns an empty array when requested times is zero' do
      expected = repeatedly(0){ 1 }
      expected.should be_empty
    end

    it 'returns an array with all nil values when no block is given' do
      expected = repeatedly(10)
      expected.length.should eq 10
      expected.each do |elem|
        elem.should be_nil
      end
    end

    it 'iterates the requested number of times and puts the results into an array' do
      expected = repeatedly(10){ 5 }
      expected.length.should eq 10
      expected.each do |elem|
        elem.should eq 5
      end
    end

    it 'passes the initial value to the first iteration' do
      @expected = nil
      repeatedly(1,100){|previous| @expected = previous }
      @expected.should eq 100
    end

    it 'passes the result of each iteration to the next iteration' do
      expected = repeatedly(10, 1){|previous| previous * 2 }
      expected.should eq [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024]
    end
  end

  context '#retro' do

    it 'does not run the block if requested times is zero' do
      @expected = true
      retro(0){ @expected = false }
      @expected.should be_true
    end

    it 'passes all arguments to the block' do
      @expected = nil
      retro(1, ?a, ?b, ?c){|*args| @expected = args }
      @expected.should eq [?a, ?b, ?c]
    end

    it 'calls the block once if the first pass is successful' do
      @expected = 0
      retro(5){ @expected += 1 }
      @expected.should eq 1
    end

    it 'calls the block more than once if the first pass fails' do
      @expected = 0
      retro(5) do
        @expected += 1
        raise StandardError if @expected < 3
      end
      @expected.should eq 3
    end

    it 'calls the block no more than the requested number of times' do
      @expected = 0
      retro(5) do
        @expected += 1
        raise StandardError
      end
      @expected.should eq 5
    end

    it 'returns true if any attempt succeeds' do
      expected = retro(1){ nil }
      expected.should be_true
    end

    it 'returns false if all attempts fail' do
      expected = retro(1){ raise StandardError }
      expected.should be_false
    end

    it 'returns false if no block is given' do
      expected = retro(10)
      expected.should eq false
    end
  end

  if RbConfig::CONFIG['ruby_install_name'] =~ /^ruby$/i
    context '#safe' do

      it 'allows safe operations' do
        lambda {
          safe{ 1 + 1 }
        }.should_not raise_error
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

  context '#timer' do

    it 'returns [0, nil] if no block is given' do
      duration, result = timer()
      duration.should eq 0
      result.should be_nil
    end

    it 'yields to the block' do
      @expected = false
      duration, result = timer{ @expected = true }
      @expected.should be_true
    end

    it 'passes all arguments to the block' do
      @expected = nil
      duration, result = timer(1,2,3){|a,b,c| @expected = [a,b,c]}
      @expected.should eq [1,2,3]
    end

    it 'returns the duration as the first return value' do
      duration, result = timer{ sleep(0.1) }
      duration.should > 0
    end

    it 'returns the block result as the second return value' do
      duration, result = timer{ 42 }
      result.should eq 42
    end
  end
end
