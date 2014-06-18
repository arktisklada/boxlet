require "thin"
require "rack/content_length"
require "rack/chunked"


module Boxlet
  module Handlers
    class Thin
      attr_accessor :app, :params

      def initialize(app, params={})
        @app = app
        @params = params
        # super
      end

      # ported from https://github.com/rack/rack/tree/master/lib/rack/handler/thin.rb
      def start
        # environment  = ENV['RACK_ENV'] || 'development'
        # default_host = environment == 'development' ? 'localhost' : '0.0.0.0'
        host = @params.delete(:Host) || default_host
        port = @params.delete(:Port) || 8077
        # host = '0.0.0.0'
        args = [host, port, app, @params]

        # Thin versions below 0.8.0 do not support additional options
        args.pop if ::Thin::VERSION::MAJOR < 1 && ::Thin::VERSION::MINOR < 8
        server = ::Thin::Server.new(*args)
        yield server if block_given?
        server.start
      end
    end
  end
end