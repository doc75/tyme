require 'open3'
require 'date'

module Tyme
  class Manager
    def initialize( db_path = nil, last_output = nil )
      @db = db_path ? Db.new(db_path) : Db.new
      @last = last_output ? Last.new(last_output) : Last.new
    end

    def run
      @last.process.each do |user, value|
        value.each do |date, duration|
          @db.add_entry( user, date, duration )
        end
      end
      @db.save
    end

  end
end

