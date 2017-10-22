require "test_helper"
require "git_queue"
require "securerandom"
require "fileutils"

class GitQueueTest < Minitest::Test

  def setup
    @path = "/tmp/#{SecureRandom.hex(16)}"
    GitQueue::Storage.create(@path)
    @q = GitQueue::Queue.new(@path)
    @q.queue
  end

  def teardown
    FileUtils.remove_dir(@path)
  end

  def test_that_it_has_a_version_number
    refute_nil ::GitQueue::VERSION
  end

  def test_git_queue_behavior
    @q.push("task1")
    @q.push("task2")
    assert_equal("task1", @q.pop)
    @q.push("task3")
    @q.up(1)

    assert_equal(["task3", "task2"], @q.queue)
  end

  def test_git_queue_multibite_string
    @q.push("仕事")
    @q.push("休息")

    assert_equal(["仕事", "休息"], @q.queue)
  end
end
