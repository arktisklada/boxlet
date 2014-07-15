require "yaml"
require "rack/contrib"
require "boxlet/version"
require "boxlet/app"
require "boxlet/config"
require "boxlet/runner"
require "pp" #unless ENV['RACK_ENV'] == 'production'


APP_ROOT = Dir.pwd


module Boxlet

  extend self
  extend Boxlet::Config

  attr_accessor :runner, :config, :raw_params, :raw_config

  def run!(argv, command='run', config_file='config.yml', &blk)
    populate_params!(argv, config_file)
    app = Boxlet::App.new

    case command
      when 'run'
        @runner = Boxlet::Runner.new
        @runner.start(app.bind, &blk)
      else
        app.send(command, Boxlet.config)
    end

    app
  end

  def stop!
    @runner.stop
    app
  end


  def debug?
    @config[:debug] == true ? true : false
  end

  def config
    @config
  end

  def params
    @params
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