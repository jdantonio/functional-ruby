require 'spec_helper'

module Functional

  describe EventMachineDeferProxy do

    subject { EventMachineDeferProxy.new }

    context '#post' do

      it 'proxies a call without arguments' do
        @expected = false
        EventMachine.run do
          subject.post{ @expected = true }
          sleep(1)
          EventMachine.stop
        end
        @expected.should eq true
      end

      it 'proxies a call with arguments' do
        @expected = []
        EventMachine.run do
          subject.post(1,2,3){|*args| @expected = args }
          sleep(1)
          EventMachine.stop
        end
        @expected.should eq [1,2,3]
      end

      it 'aliases #<<' do
        @expected = false
        EventMachine.run do
          subject << proc{ @expected = true }
          sleep(1)
          EventMachine.stop
        end
        @expected.should eq true
      end
    end
  end
end
