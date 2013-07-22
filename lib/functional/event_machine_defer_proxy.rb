require 'functional/global_thread_pool'

module Functional

  class EventMachineDeferProxy
    behavior(:global_thread_pool)

    def post(*args, &block)
      if args.empty?
        EventMachine.defer(nil, nil, &block)
      else
        new_block = proc{ block.call(*args) }
        EventMachine.defer(nil, nil, &new_block)
      end
      return true
    end

    def <<(block)
      self.post(&block)
      return self
    end
  end
end
