require "rack/contrib"
require "boxlet/version"
require "boxlet/app"
require "boxlet/arguments"
require "boxlet/runner"


module Boxlet

  extend self
  extend Boxlet::Arguments

  attr_accessor :runner

  def run!(argv, &blk)
    params = parse_input(argv)
    app = Boxlet::App.new(params).bind
    runner = Boxlet::Runner.new
    runner.start(app, params, &blk)
  end

  def stop!
    runner.stop
  end

end