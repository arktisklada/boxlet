require 'handlers/thin'


module Boxlet
  class Runner
    attr_accessor :server, :server_instance

    def start(app, &block)
      params = Boxlet.config
      environment  = ENV['RACK_ENV'] || params[:environment] rescue 'development'
      default_host = environment == 'development' ? 'localhost' : '0.0.0.0'

      params[:Host] = params.delete(:host) || default_host
      params[:Port] = params.delete(:port) || 8077

      server_type = params.delete(:server_type) || :thin
      @server_instance = self.send server_type.to_sym, app, params
      @server_instance.start do |server|
        self.server = server
        block.call(server) if block_given?
      end
    end

    def stop
      @server.stop!
    end

    def rack(app, params)
      Rack::Server.new(params.merge({app: app}))
    end

    def thin(app, params)
      Boxlet::Handlers::Thin.new(app, params)
    end

  end
end