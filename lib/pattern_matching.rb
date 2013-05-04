require 'pattern_matching/version'

module PatternMatching

  def self.included(base)

    class << base

      def defn(func, *args, &block)
        #puts "Defining function ##{func} with args #{args}"
        #if block_given?
          #self.send(:define_method, func, &block)
        #else
          #self.send(:define_method, func){}
        #end
      end

    end
  end
end
