require 'thread'

module Functional

  ImmutablityError = Class.new(StandardError)

  module Final

    def thread_safe_final
      @__final_attribute_mutex__ = Mutex.new
    end

    def self.included(base)
      base.extend(ClassMethods)
      super(base)
    end

    # @!visibility private
    module ClassMethods

      def final_attribute(name)
        self.send(:define_method, name.to_sym){ nil }
        self.send(:define_method, "#{name}?".to_sym){ false }
        self.send(:define_method, "#{name}=".to_sym){|value|
          if @__final_attribute_mutex__ && ! @__final_attribute_mutex__.try_lock
            raise ImmutablityError.new("final accessor '#{name}' has already been set")
          end
          singleton = class << self; self end 
          singleton.send(:define_method, "#{name}?".to_sym){ true }
          singleton.send(:define_method, name.to_sym){ value }
          singleton.send(:define_method, "#{name}=".to_sym) {|value|
            raise ImmutablityError.new("final accessor '#{name}' has already been set")
          }
          @__final_attribute_mutex__.unlock if @__final_attribute_mutex__
          value
        }
      end
    end
  end
end
