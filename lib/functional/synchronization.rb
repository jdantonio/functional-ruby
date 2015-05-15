module Functional

  # @!visibility private
  #
  # Based on work originally done by Petr Chalupa (@pitr-ch) in Concurrent Ruby.
  # https://github.com/ruby-concurrency/concurrent-ruby/blob/master/lib/concurrent/synchronization/object.rb
  module Synchronization

    if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'

      require 'jruby'

      # @!visibility private
      class Object

        # @!visibility private
        def initialize(*args)
        end

        protected

        # @!visibility private
        def synchronize
          JRuby.reference0(self).synchronized { yield }
        end

        # @!visibility private
        def ensure_ivar_visibility!
          # relying on undocumented behavior of JRuby, ivar access is volatile
        end
      end

    elsif defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx'

      # @!visibility private
      class Object

        # @!visibility private
        def initialize(*args)
        end

        protected

        # @!visibility private
        def synchronize(&block)
          Rubinius.synchronize(self, &block)
        end

        # @!visibility private
        def ensure_ivar_visibility!
          # Rubinius instance variables are not volatile so we need to insert barrier
          Rubinius.memory_barrier
        end
      end

    else

      require 'thread'

      # @!visibility private
      class Object

        # @!visibility private
        def initialize(*args)
          @__lock__      = ::Mutex.new
          @__condition__ = ::ConditionVariable.new
        end

        protected

        # @!visibility private
        def synchronize
          if @__lock__.owned?
            yield
          else
            @__lock__.synchronize { yield }
          end
        end

        # @!visibility private
        def ensure_ivar_visibility!
          # relying on undocumented behavior of CRuby, GVL acquire has lock which ensures visibility of ivars
          # https://github.com/ruby/ruby/blob/ruby_2_2/thread_pthread.c#L204-L211
        end
      end
    end
  end
end
