require 'thread'

module Functional

  # [agent](http://clojuredocs.org/clojure_core/clojure.core/agent)
  # [set-error-handler!](http://clojuredocs.org/clojure_core/clojure.core/set-error-handler!)
  # [restart-agent](http://clojuredocs.org/clojure_core/clojure.core/restart-agent)
  # [send](http://clojuredocs.org/clojure_core/clojure.core/send)
  # [send-off](http://clojuredocs.org/clojure_core/clojure.core/send-off)
  # [agent-error](http://clojuredocs.org/clojure_core/clojure.core/agent-error)
  # [release-pending-sends](http://clojuredocs.org/clojure_core/clojure.core/release-pending-sends)
  # [add-watch](http://clojuredocs.org/clojure_core/clojure.core/add-watch)
  # [set-validator](http://clojuredocs.org/clojure_core/clojure.core/set-validator!)
  # [deref](http://clojuredocs.org/clojure_core/clojure.core/deref)

  # An agent is a single atomic value that represents an identity. The current value
  # of the agent can be requested at any time (#deref). Each agent has a work queue and operates on
  # its own thread (or a thread from the shared pool). Consumers can #send code blocks to the
  # agent. The code block (function) will receive the current value of the agent as its sole
  # parameter. The return value of the block will become the new value of the agent. Agents support
  # two error handling modes: fail and continue. A good example of an agent is a shared incrementing
  # counter.
  class Agent
  end
end
