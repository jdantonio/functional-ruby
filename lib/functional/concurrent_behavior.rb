require 'functional/behavior'

module Kernel

  def deref(future)
    if future.respond_to?(:deref)
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
    else
      return false
    end
  end
  module_function :fulfilled?

  def realized?(future)
    if future.respond_to?(:realized?)
      return future.realized?
    else
      return false
    end
  end
  module_function :realized?

  def rejected?(future)
    if future.respond_to?(:rejected?)
      return future.rejected?
    else
      return false
    end
  end
  module_function :rejected?
end
