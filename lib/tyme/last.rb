require 'open3'
require 'date'

module Tyme
  class Last
    def initialize( last_output = nil )
      if last_output
        @stdin = nil
        @stdout = last_output
        @stderr = nil
      else
        @stdin, @stdout, @stderr = Open3.popen3('last --time-format iso -R | grep tty')
      end
    end

    def process
      lines = @stdout.readlines
      return nil if lines.empty?
      data = lines.select { |line| not line.include? 'gone' }.map { |line| parse_line(line) }
      consolidate(data)
    end

    private
      def consolidate( data )
        ret={}
        data.each do |elt|
          user = elt[:user]
          date = elt[:date]
          ret[user] ||= { date => 0 }
          ret[user][date] += elt[:duration] 
        end
        ret
      end
      
      def parse_line( line )
        values = line.scan( /(\S+)\s+tty\d+\s+(\S+)\s+-?\s+\S+\s+\((\d+):(\d+)\)/ )[0]
        date = DateTime.parse( values[1] ).strftime('%F')
        { user: values[0].to_sym,  date: date.to_sym, duration: values[2].to_i*60 + values[3].to_i }
      end
  end
end

