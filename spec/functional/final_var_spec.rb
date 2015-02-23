module Functional

  describe FinalVar do

    context 'instanciation' do

      it 'is unset when no arguments given' do
        expect(FinalVar.new).to_not be_set
      end

      it 'is set with the given argument' do
        expect(FinalVar.new(41)).to be_set
      end
    end

    context '#get' do

      subject { FinalVar.new }

      it 'returns nil when unset' do
        expect(subject.get).to be nil
      end

      it 'returns the value when set' do
        expect(FinalVar.new(42).get).to eq 42
      end

      it 'is aliased as #value' do
        expect(subject.value).to be nil
        subject.set(42)
        expect(subject.value).to eq 42
      end
    end

    context '#set' do

      subject { FinalVar.new }

      it 'sets the value when unset' do
        subject.set(42)
        expect(subject.get).to eq 42
      end

      it 'returns the new value when unset' do
        expect(subject.set(42)).to eq 42
      end

      it 'raises an exception when already set' do
        subject.set(42)
        expect {
          subject.set(42)
        }.to raise_error(Functional::FinalityError)
      end

      it 'is aliased as #value=' do
        subject.value = 42
        expect(subject.get).to eq 42
      end
    end

    context '#set?' do

      it 'returns false when unset' do
        expect(FinalVar.new).to_not be_set
      end

      it 'returns true when set' do
        expect(FinalVar.new(42)).to be_set
      end

      it 'is aliased as value?' do
        expect(FinalVar.new.value?).to be false
        expect(FinalVar.new(42).value?).to be true
      end
    end

    context '#get_or_set' do

      it 'sets the value when unset' do
        subject = FinalVar.new
        subject.get_or_set(42)
        expect(subject.get).to eq 42
      end

      it 'returns the new value when previously unset' do
        subject = FinalVar.new
        expect(subject.get_or_set(42)).to eq 42
      end

      it 'returns the current value when already set' do
        subject = FinalVar.new(100)
        expect(subject.get_or_set(42)).to eq 100
      end
    end

    context '#fetch' do

      it 'returns the given default value when unset' do
        subject = FinalVar.new
        expect(subject.fetch(42)).to eq 42
      end

      it 'does not change the current value when unset' do
        subject = FinalVar.new
        subject.fetch(42)
        expect(subject.get).to be nil
      end

      it 'returns the current value when already set' do
        subject = FinalVar.new(100)
        expect(subject.get_or_set(42)).to eq 100
      end
    end

    context 'reflection' do

      specify '#eql? returns false when unset' do
        expect(FinalVar.new.eql?(nil)).to be false
        expect(FinalVar.new.eql?(42)).to be false
        expect(FinalVar.new.eql?(FinalVar.new.value)).to be false
      end

      specify '#eql? returns false when set and the value does not match other' do
        subject = FinalVar.new(42)
        expect(subject.eql?(100)).to be false
      end

      specify '#eql? returns true when set and the value matches other' do
        subject = FinalVar.new(42)
        expect(subject.eql?(42)).to be true
      end

      specify '#eql? returns true when set and other is a FinalVar with the same value' do
        subject = FinalVar.new(42)
        other = FinalVar.new(42)
        expect(subject.eql?(other)).to be true
      end

      specify 'aliases #== as #eql?' do
        expect(FinalVar.new == nil).to be false
        expect(FinalVar.new == 42).to be false
        expect(FinalVar.new == FinalVar.new).to be false
        expect(FinalVar.new(42) == 42).to be true
        expect(FinalVar.new(42) == FinalVar.new(42)).to be true
      end

      specify '#inspect includes the word "value" and the value when set' do
        subject = FinalVar.new(42)
        expect(subject.inspect).to match(/value\s?=\s?42\s*>$/)
      end

      specify '#inspect include the word "unset" when unset' do
        subject = FinalVar.new
        expect(subject.inspect).to match(/unset\s*>$/i)
      end

      specify '#to_s returns nil as a string when unset' do
        expect(FinalVar.new.to_s).to eq nil.to_s
      end

      specify '#to_s returns the value as a string when set' do
        expect(FinalVar.new(42).to_s).to eq 42.to_s
        expect(FinalVar.new('42').to_s).to eq '42'
      end
    end
  end
end
