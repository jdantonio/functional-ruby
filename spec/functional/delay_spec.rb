module Functional

  describe Delay do

    let!(:fulfilled_value) { 10 }
    let!(:rejected_reason) { StandardError.new('mojo jojo') }

    let(:pending_subject) do
      Delay.new{ fulfilled_value }
    end

    let(:fulfilled_subject) do
      delay = Delay.new{ fulfilled_value }
      delay.tap{ delay.value }
    end

    let(:rejected_subject) do
      delay = Delay.new{ raise rejected_reason }
      delay.tap{ delay.value }
    end

    specify{ Functional::Protocol::Satisfy! Delay, :Disposition }

    context '#initialize' do

      it 'sets the state to :pending' do
        expect(Delay.new{ nil }.state).to eq :pending
        expect(Delay.new{ nil }).to be_pending
      end

      it 'raises an exception when no block given' do
        expect {
          Delay.new
        }.to raise_error(ArgumentError)
      end
    end

    context '#state' do

      it 'is :pending when first created' do
        f = pending_subject
        expect(f.state).to eq(:pending)
        expect(f).to be_pending
      end

      it 'is :fulfilled when the handler completes' do
        f = fulfilled_subject
        expect(f.state).to eq(:fulfilled)
        expect(f).to be_fulfilled
      end

      it 'is :rejected when the handler raises an exception' do
        f = rejected_subject
        expect(f.state).to eq(:rejected)
        expect(f).to be_rejected
      end
    end

    context '#value' do

      let(:task){ proc{ nil } }

      it 'blocks the caller when :pending and timeout is nil' do
        f = pending_subject
        expect(f.value).to be_truthy
        expect(f).to be_fulfilled
      end

      it 'is nil when :rejected' do
        expected = rejected_subject.value
        expect(expected).to be_nil
      end

      it 'is set to the return value of the block when :fulfilled' do
        expected = fulfilled_subject.value
        expect(expected).to eq fulfilled_value
      end

      it 'does not call the block before #value is called' do
        expect(task).not_to receive(:call).with(any_args)
        Delay.new(&task)
      end

      it 'calls the block when #value is called' do
        expect(task).to receive(:call).once.with(any_args).and_return(nil)
        Delay.new(&task).value
      end

      it 'only calls the block once no matter how often #value is called' do
        expect(task).to receive(:call).once.with(any_args).and_return(nil)
        delay = Delay.new(&task)
        5.times{ delay.value }
      end
    end

    context '#reason' do

      it 'is nil when :pending' do
        expect(pending_subject.reason).to be_nil
      end

      it 'is nil when :fulfilled' do
        expect(fulfilled_subject.reason).to be_nil
      end

      it 'is set to error object of the exception when :rejected' do
        expect(rejected_subject.reason).to be_a(Exception)
        expect(rejected_subject.reason.to_s).to match(/#{rejected_reason}/)
      end
    end

    context 'predicates' do

      specify '#value? returns true when :fulfilled' do
        expect(pending_subject).to_not be_value
        expect(fulfilled_subject).to be_value
        expect(rejected_subject).to_not be_value
      end

      specify '#reason? returns true when :rejected' do
        expect(pending_subject).to_not be_reason
        expect(fulfilled_subject).to_not be_reason
        expect(rejected_subject).to be_reason
      end

      specify '#fulfilled? returns true when :fulfilled' do
        expect(pending_subject).to_not be_fulfilled
        expect(fulfilled_subject).to be_fulfilled
        expect(rejected_subject).to_not be_fulfilled
      end

      specify '#rejected? returns true when :rejected' do
        expect(pending_subject).to_not be_rejected
        expect(fulfilled_subject).to_not be_rejected
        expect(rejected_subject).to be_rejected
      end

      specify '#pending? returns true when :pending' do
        expect(pending_subject).to be_pending
        expect(fulfilled_subject).to_not be_pending
        expect(rejected_subject).to_not be_pending
      end
    end
  end
end
