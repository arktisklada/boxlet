require "handlers/thin"


module Boxlet
  class Runner

    attr_accessor :server, :server_instance

    def start(app, params, &block)
      server_type = params.delete(:server_type) || :thin
      @server_instance = self.send server_type.to_sym
      @server_instance.run(app, params) do |server|
        self.server = server
        block.call(server) if block_given?
      end
    end

    def stop
      @server.stop!
    end

    def thin
      Boxlet::Handlers::Thin.new
    end

  end
end