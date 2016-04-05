require 'yaml'
require 'rack/contrib'
require 'boxlet/version'
require 'boxlet/app'
require 'boxlet/log'
require 'boxlet/config'
require 'boxlet/runner'

APP_ROOT = Dir.pwd

module Boxlet
  extend self
  extend Boxlet::Config

  PUBLIC_COMMANDS = {
    run: "Run the Boxlet server",
    stop: "Stop a daemonized server"
  }.freeze

  attr_accessor :runner, :config, :raw_params, :raw_config

  def run!(argv, command='run', config_file='config.yml', &blk)
    populate_params!(argv, config_file)
    @log = Boxlet::Log.new(@config[:log_file], (debug? ? Logger::DEBUG : Logger::INFO))
    @app = Boxlet::App.new

    command = command.to_s.to_sym
    case command
    when :run
      Boxlet.log(:debug, @config)
      @runner = Boxlet::Runner.new
      @runner.start(@app.bind, &blk)
    when :stop
      if @config[:daemonize] == true
        pid = File.read(@config[:pid_file]).to_i
        puts "Killing #{pid}..."
        Process.kill(Signal.list["TERM"], pid)
      end
    else
      if App::PUBLIC_COMMANDS.keys.include?(command)
        @app.send(command, argv)
      else
        print_menu
      end
    end

    @app
  end

  def stop!
    @runner.stop
    @app
  end

  def debug?
    @config[:debug] == true
  end

  def config
    @config
  end

  def params
    @params
  end

  def log(level, message)
    @log.write(level, message)
  end

  private

    def print_menu
      puts "Usage: boxlet command [args]"
      puts
      puts "Common commands:"
      commands_with_descriptions = PUBLIC_COMMANDS.merge(App::PUBLIC_COMMANDS)
      commands = commands_with_descriptions.keys
      max_command_chars = commands.sort { |a, b| a.length <=> b.length }.last.length
      PUBLIC_COMMANDS.each do |command, description|
        print_menu_command command, max_command_chars, description
      end

      puts
      puts "Additional commands:"
      App::PUBLIC_COMMANDS.each do |command, description|
        print_menu_command command, max_command_chars, description
      end

    end

    def print_menu_command(command, max_command_chars, description)
      puts "  #{command.to_s.ljust(max_command_chars)}   #{description}"
    end
end

# Configure our temporary folder
class Dir  
  def Dir::tmpdir
    tmp = './tmp'
    if $SAFE > 0
      tmp = @@systmpdir
    else
      for dir in [ENV['TMPDIR'], ENV['TMP'], ENV['TEMP'], @@systmpdir, '/tmp']
        if dir and stat = File.stat(dir) and stat.directory? and stat.writable?
          tmp = dir
          break
        end rescue nil
      end
      File.expand_path(tmp)
    end
  end
end
