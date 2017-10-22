require 'minitest/autorun'
require 'git_queue/queue'

module GitQueue
  class TestQueue < Minitest::Test

    class StorageForTest
      def initialize; @queue = []; @history = []; end
      def load_queue; @queue; end
      def store_queue(queue, message); @history << message; @queue = queue; end
      def history(length = nil); length ||= @history.size; @history[0..(length - 1)]; end
    end

    def setup
      @target = Queue.new('test')
      @target.__send__(:instance_variable_set, :@storage, StorageForTest.new)
    end

    def test_queue_insert
      @target << "task1"
      @target.push("task2")
      @target.push("task3")

      assert_equal(["task1", "task2", "task3"], @target.queue)
    end

    def test_queue_pop
      @target << "task1"
      @target << "task2"
      @target << "task3"

      assert_equal("task1", @target.pop)
      assert_equal(["task2", "task3"], @target.queue)
    end

    def test_queue_switch
      @target << "task1"
      @target << "task2"
      @target << "task3"

      @target.switch(0, 2)
      assert_equal(["task3", "task2", "task1"], @target.queue)
      @target.switch(1, 2)
      assert_equal(["task3", "task1", "task2"], @target.queue)
    end

    def test_queue_switch_failed
      @target << "task1"
      @target << "task2"

      @target.switch(0,3)
      assert_equal(["task1", "task2"], @target.queue)
    end

    def test_queue_up
      @target << "task1"
      @target << "task2"
      @target << "task3"

      @target.up(2)
      assert_equal(["task1", "task3", "task2"], @target.queue)
      @target.up(1)
      assert_equal(["task3", "task1", "task2"], @target.queue)
    end

    def test_queue_up_failed
      @target << "task1"
      @target << "task2"

      @target.up(2)
      assert_equal(["task1", "task2"], @target.queue)
    end

    def test_queue_up_with_minimum_index
      @target << "task1"
      @target << "task2"
      @target << "task3"

      @target.up(0)
      assert_equal(["task1", "task2", "task3"], @target.queue)
    end

    def test_queue_down
      @target << "task1"
      @target << "task2"
      @target << "task3"

      @target.down(0)
      assert_equal(["task2", "task1", "task3"], @target.queue)
      @target.down(1)
      assert_equal(["task2", "task3", "task1"], @target.queue)
    end

    def test_queue_down_failed
      @target << "task1"
      @target << "task2"

      @target.down(2)
      assert_equal(["task1", "task2"], @target.queue)
    end

    def test_queue_down_with_maximum_index
      @target << "task1"
      @target << "task2"
      @target << "task3"

      @target.down(2)
      assert_equal(["task1", "task2", "task3"], @target.queue)
    end

    def test_queue_history
      GitQueue::Queue::Configure.push_message do |item|
        "Add a item #{item}"
      end

      GitQueue::Queue::Configure.pop_message do |item|
        "Pop a item #{item}"
      end

      GitQueue::Queue::Configure.switch_message do |left, right|
        "Exchange #{left} for #{right}"
      end

      @target.push("task1")
      @target.push("task2")
      @target.push("task3")
      @target.pop
      @target.switch(0, 1)

      assert_equal(["Add a item task1", "Add a item task2", "Add a item task3", "Pop a item task1", "Exchange task2 for task3"], @target.history)
      assert_equal(["Add a item task1", "Add a item task2"], @target.history(2))
    end
  end
end
