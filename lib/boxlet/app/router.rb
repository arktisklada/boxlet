require "rack/request"
require "rack/response"
require "boxlet/app/controller"
require "json"


module Boxlet
  class Router

    attr_accessor :method, :action

    def initialize(method, action)
      @method = method
      @action = action
    end

    def call(env)
      request = Rack::Request.new(env)

      # puts "#{@method} #{@action} #{request.get?} #{request.post?}" if Boxlet::Config::debug?

      response = Rack::Response.new
      controller = Boxlet::Controller.new(request)
      if (@method == :* || request.get? && @method == :get) || (request.post? && @method == :post)
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