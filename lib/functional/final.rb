module Functional

  ImmutablityError = Class.new(StandardError)

  module Final

    def self.included(base)
      base.extend(ClassMethods)
      super(base)
    end

    # @!visibility private
    module ClassMethods

      def final_attribute(name, *names)
        (names << name).each do |func|
          self.send(:define_method, func.to_sym){ nil }
          self.send(:define_method, "#{func}?".to_sym){ false }
          self.send(:define_method, "#{func}=".to_sym){|value|
            singleton = class << self; self end 
            singleton.send(:define_method, "#{func}?".to_sym){ true }
            singleton.send(:define_method, func.to_sym){ value }
            singleton.send(:define_method, "#{func}=".to_sym) {|value|
              raise ImmutablityError.new("final accessor '#{func}' has already been set")
            }
            value
          }
        end
      end
    end
  end
end
