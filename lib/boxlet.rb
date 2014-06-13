require "yaml"
require "rack/contrib"
require "boxlet/version"
require "boxlet/app"
require "boxlet/config"
require "boxlet/runner"
require "pp" unless ENV['RACK_ENV'] == 'production'


APP_ROOT = Dir.pwd


module Boxlet

  extend self
  extend Boxlet::Config

  attr_accessor :runner, :params, :config

  def run!(argv, &blk)
    populate_params!(argv, 'config.yml')
    
    # params[:app] = Boxlet::App.new(params).bind
    # params[:Port] = params.delete(:port) || 8077
    # params[:Host] = params.delete(:host) || 'localhost'
    # Rack::Server.start(params)
    app = Boxlet::App.new(@params).bind
    @runner = Boxlet::Runner.new
    @runner.start(app, @params, &blk)
    return app
  end

  def stop!
    @runner.stop
    return app
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