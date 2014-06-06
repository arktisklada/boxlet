require "rack/request"
require "rack/response"
require "boxlet/app/controller"


module Boxlet
  class Router

    attr_accessor :method, :action

    def initialize(method, action)
      @method = method.to_sym
      @action = action.to_sym
    end

    def call(env)
      request = Rack::Request.new(env)

      response = Rack::Response.new
      controller = Boxlet::Controller.new(request)
      if (request.get? && @method == :get) || (request.post? && @method == :post)
        action_response = controller.action(@action)
        response.status = 200
      else
        response.status = 404
        raise "404"
      end

      if action_response[:format] == :json
        response.write action_response[:content].to_json
      else
        response.write action_response[:content]
      end

      response.finish
    end

  end
end