require 'logger'
require 'fileutils'
require 'pp'


module Boxlet
  class Log
    attr_accessor :log

    # The levels are:
    #   UNKNOWN: An unknown message that should always be logged.
    #   FATAL: An unhandleable error that results in a program crash.
    #   ERROR: A handleable error condition.
    #   WARN: A warning.
    #   INFO: Generic (useful) information about system operation.
    #   DEBUG: Low-level information for developers.
    def initialize(filename, level, rotation=10, max_size=1024000)
      # create the directory for the log if it doesn't exist
      if !File.exist? File.dirname(filename)
        FileUtils.mkdir_p File.dirname(filename)
      end

      @log ||= Logger.new(filename, rotation, max_size)
      @log.level = level
      @log
    end

    # Possible levels: (:debug, :info, :warn, :error, :fatal)
    def write(level, message)
      if Boxlet.debug?
        if message.is_a? String
          puts message
        else
          pp message
        end
      else
        if level == :info
          pp message
        end
        @log.call(level, message)
      end
    end
  end
end
