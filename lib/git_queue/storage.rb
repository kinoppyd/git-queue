require "rugged"

module GitQueue
  QUEUE_FILE_NAME = "QUEUE"

  # Backend storage
  class Storage
    attr_reader :path

    def self.create(path)
      Rugged::Repository.init_at(path)
    end

    def initialize(path)
      @path = path
    end

    def load_queue
      return [] if driver.empty?
      sha = driver.head.target.tree.get_entry(QUEUE_FILE_NAME)[:oid]
      driver.lookup(sha).content.force_encoding("UTF-8").split("\n")
    end

    def store_queue(queue, message)
      oid = driver.write(queue.join("\n"), :blob)
      index = driver.index
      index.add( path: QUEUE_FILE_NAME, oid: oid, mode: 0100644)
      Rugged::Commit.create(
        driver,
        tree: index.write_tree(driver),
        author: author,
        committer: author,
        parents: parents,
        update_ref: 'HEAD',
        message: message
      )
      load_queue
    end

    def history(size = nil)
      walker = Rugged::Walker.new(driver)
      walker.push(driver.head.target.oid)
      histories = []
      walker.each_with_index do |commit, index|
        break if size && index > size - 1
        histories << commit.message
      end
      walker.reset
      histories
    end

    private

    def driver
      @driver ||= init_driver
    end

    def init_driver
      Rugged::Repository.new(path)
    end

    def author
      { email: 'test@example.com', name: 'gitqueue', time: Time.now }
    end

    def parents
      driver.empty? ? [] : [driver.head.target].compact
    end
  end
end
