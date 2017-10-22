require 'minitest/autorun'
require 'securerandom'
require 'fileutils'

module GitQueue
  class TestStorage < Minitest::Test
    def setup
      @rand_repo_name = "/tmp/#{SecureRandom.hex(16)}"
      Storage.create(@rand_repo_name)
      @storage = Storage.new(@rand_repo_name)
    end

    def teardown
      FileUtils.remove_dir(@rand_repo_name)
    end

    def test_create_storage
      storage = Storage.new(@rand_repo_name)
      assert_same(@storage.path, storage.path)
    end

    def test_not_initialized_storage
      assert_raises(Rugged::OSError) do
        s = Storage.new("/tmp/#{SecureRandom.hex(20)}")
        s.load_queue
      end
    end

    def test_store_and_load_queue
      queue = [
        'task1',
        'task2',
        'task3',
        'task4'
      ]
      @storage.store_queue(queue, 'initial queue')

      assert_equal(queue, @storage.load_queue)
    end

    def test_store_and_read_many_times
      queue1 = ['task1', 'task2', 'task3', 'task4']
      @storage.store_queue(queue1, 'first queue')
      assert_equal(queue1, @storage.load_queue)

      queue2 = ['task1', 'task2', 'task3', 'task4', 'task5', 'task6']
      @storage.store_queue(queue2, 'second queue')
      assert_equal(queue2, @storage.load_queue)

      queue3 = ['task1', 'task2', 'task7']
      @storage.store_queue(queue3, 'third queue')
      assert_equal(queue3, @storage.load_queue)
    end

    def test_read_all_histories
      @storage.store_queue([1,2,3], 'first')
      @storage.store_queue([1,2,3,4], 'second')
      @storage.store_queue([1,2,3,4,5], 'third')
      assert_equal(["third", "second", "first"], @storage.history)
    end

    def test_read_required_size_histories
      @storage.store_queue([1,2,3], 'first')
      @storage.store_queue([1,2,3,4], 'second')
      @storage.store_queue([1,2,3,4,5], 'third')
      assert_equal(["third", "second"], @storage.history(2))
    end
  end
end
