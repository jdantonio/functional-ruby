require 'thread'

require 'functional/thread_pool'
require 'functional/utilities'

module Functional

  def self.new_cached_thread_pool
    return CachedThreadPool.new
  end

  class CachedThreadPool < ThreadPool
    behavior(:thread_pool)

    attr_reader :working

    def initialize
      super()
      @working = 0
      @mutex = Mutex.new
    end

    def kill
      @status = :shutdown
      @pool.each{|t| Thread.kill(t.thread) }
    end

    def size
      return @pool.length
    end

    def post(*args, &block)
      raise ArgumentError.new('no block given') unless block_given?
      if running?
        collect_garbage if @pool.empty?
        @mutex.synchronize do
          if @working >= @pool.length
            create_worker_thread
          end
          @queue << [args, block]
        end
        return true
      else
        return false
      end
    end

    # @private
    def status # :nodoc:
      @pool.collect{|t| t.thread.status }
    end

    private

    Worker = Struct.new(:status, :idletime, :thread)

    # @private
    def create_worker_thread # :nodoc:
      worker = Worker.new(:starting, nil, nil)

      worker.thread = Thread.new(worker) do |me|
        loop do
          @working -= 1
          me.status = :idle
          me.idletime = timestamp

          task = @queue.pop

          @working += 1
          me.status = :working

          if task == :stop
            me.status = :stopping
            break
          else
            task.last.call(*task.first)
          end
        end

        @pool.delete(me)
        if @pool.empty?
          @termination.set
          @status = :terminated
        end
      end

      @pool << worker
      @working += 1
    end

    # @private
    def collect_garbage # :nodoc:
      @collector = Thread.new do
        loop do
          sleep(60)
          @mutex.synchronize do
            @pool.reject! do |worker|
              worker.thread.status.nil? ||
                (worker.status == :idle && 60 >= delta(worker.idletime, timestamp))
            end
          end
          break if @pool.empty?
        end
      end
    end
  end
end
