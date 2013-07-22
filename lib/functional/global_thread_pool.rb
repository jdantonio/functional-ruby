require 'functional/cached_thread_pool'

$GLOBAL_THREAD_POOL ||= Functional::CachedThreadPool.new
