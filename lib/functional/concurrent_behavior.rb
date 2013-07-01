require 'functional/behavior'

behavior_info(:future,
              value: -1,
              pending?: 0,
              fulfilled?: 0)

behavior_info(:promise,
              state: 0,
              value: -1,
              pending?: 0,
              fulfilled?: 0,
              rejected?: 0,
              then: 0,
              rescue: -1)

module Kernel

  def deref(future)
    if future.respond_to?(:deref)
      return future.deref
    elsif future.respond_to?(:value)
      return future.deref
    else
      return nil
    end
  end
  module_function :deref

  def pending?(future)
    if future.respond_to?(:pending?)
      return future.pending?
    else
      return false
    end
  end
  module_function :pending?

  def fulfilled?(future)
    if future.respond_to?(:fulfilled?)
      return future.fulfilled?
    elsif future.respond_to?(:realized?)
      return future.realized?
    else
      return false
    end
  end
  module_function :fulfilled?

  def realized?(future)
    if future.respond_to?(:realized?)
      return future.realized?
    elsif future.respond_to?(:fulfilled?)
      return future.fulfilled?
    else
      return false
    end
  end
  module_function :realized?

  def rejected?(promise)
    if promise.respond_to?(:rejected?)
      return promise.rejected?
    else
      return false
    end
  end
  module_function :rejected?
end
