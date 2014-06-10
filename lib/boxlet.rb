require "rack/contrib"
require "boxlet/version"
require "boxlet/app"
require "boxlet/arguments"
require "boxlet/runner"
require "pp"


module Boxlet

  extend self
  extend Boxlet::Arguments

  attr_accessor :runner, :params

  def run!(argv, &blk)
    @params = parse_input(argv)
    # params[:app] = Boxlet::App.new(params).bind
    # params[:Port] = params.delete(:port) || 8077
    # params[:Host] = params.delete(:host) || 'localhost'
    # Rack::Server.start(params)
    app = Boxlet::App.new(@params).bind
    runner = Boxlet::Runner.new
    runner.start(app, @params, &blk)
  end

  def stop!
    runner.stop
  end

end

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
