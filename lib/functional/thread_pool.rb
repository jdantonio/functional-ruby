require 'functional/behavior'

behavior_info(:thread_pool,
              running?: 0,
              shutdown?: 0,
              terminated?: 0,
              shutdown: 0,
              kill: 0,
              size: 0,
              wait_for_termination: -1,
              post: -1,
              :<< => 1,
              status: 0)
