require 'yaml'
require 'pathname'
require 'fileutils'

module Tyme
  class Db

    # structure
    # :user
    def initialize( file = '/var/lib/tyme/db.yml' )
      # we check if directory exist, otherwise we create it
      dir = Pathname.new(file).dirname
      FileUtils.mkdir_p dir unless Dir.exist? dir
      @db_file = file
      @db = {}
    end

    def add_entry(user,date,duration)
      load_db
      @db[user.to_sym] ||= {}
      @db[user.to_sym][date.to_sym] = duration
    end

    def save
      save_db
    end

    private
      def load_db
        @db = YAML.load_file(@db_file) if (@db.empty? && File.exist?(@db_file))
      end

      def save_db
        File.open(@db_file, 'w') {|f| f.write @db.to_yaml }
      end
  end
end
