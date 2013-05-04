require 'pattern_matching/version'

module PatternMatching

  def self.included(base)

    def __pattern_match__(func, *args, &block)
      #puts "Calling function ##{func} with args #{args}"
    end

    class << base

      def defn(func, *args, &block)
        #puts "Defining function ##{func} with args #{args}"
        block = Proc.new{} unless block_given?
        self.send(:define_method, func) do |*args, &block|
          __pattern_match__(func, *args, block)
        end
      end

    end
  end
end
