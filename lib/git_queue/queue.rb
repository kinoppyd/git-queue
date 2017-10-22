require "git_queue/storage"

module GitQueue
  # Queue
  class Queue
    @@push_message = -> (item) { "Add item #{item}" }
    @@pop_message = -> (item) { "Pop item #{item}" }
    @@switch_message = -> (left, right) { "Switch #{left} with #{right}" }

    class Configure
      class << self
        def push_message(&block)
          ::GitQueue::Queue.__send__(:class_variable_set, :@@push_message, block) if block_given?
        end

        def pop_message(&block)
          ::GitQueue::Queue.__send__(:class_variable_set, :@@pop_message, block) if block_given?
        end

        def switch_message(&block)
          ::GitQueue::Queue.__send__(:class_variable_set, :@@switch_message, block) if block_given?
        end
      end
    end

    attr_reader :name

    def initialize(name)
      @name = name
      @queue = []
    end

    def push(task)
      sync
      @queue << task
      store(@@push_message.call(task))
    end
    alias << push

    def pop
      sync
      ret = @queue.shift
      store(@@pop_message.call(ret))
      ret
    end

    def switch(l_index, r_index)
      sync
      return queue if l_index < 0 || @queue.size - 1 < l_index
      return queue if r_index < 0 || @queue.size - 1 < r_index
      _switch(l_index, r_index)
      store(@@switch_message.call(@queue[r_index], @queue[l_index]))
    end

    def up(index)
      sync
      return queue if index <= 0 || @queue.size - 1 < index
      _switch(index, index - 1)
      store(@@switch_message.call(@queue[index - 1], @queue[index]))
    end

    def down(index)
      sync
      return queue if index < 0 || @queue.size - 2 < index
      _switch(index, index + 1)
      store(@@switch_message.call(@queue[index + 1], @queue[index]))
    end

    def history(length = nil)
      @storage.history(length)
    end

    def queue
      sync
      @queue.dup
    end

    private

    def storage
      @storage ||= init_storage(name)
    end

    def init_storage(name)
      Storage.new(name)
    end

    def sync
      @queue = storage.load_queue
    end

    def store(message)
      @queue = storage.store_queue(@queue, message)
    end

    def _switch(r_index, l_index)
      tmp = @queue[r_index]
      @queue[r_index] = @queue[l_index]
      @queue[l_index] = tmp
    end
  end
end
