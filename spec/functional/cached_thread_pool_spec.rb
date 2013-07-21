require 'spec_helper'
require_relative 'thread_pool_shared'

module Functional

  describe CachedThreadPool do

    subject { CachedThreadPool.new }

    it_should_behave_like 'Thread Pool'

  end
end
