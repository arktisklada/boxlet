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

      Boxlet.log(:info, "INFO: #{env["REMOTE_ADDR"]} - [#{Time.now.to_s}] #{@method.upcase} #{env["SERVER_PROTOCOL"]} => #{env["REQUEST_PATH"]}")

      response = Rack::Response.new
      controller = Boxlet::Controller.new(request)
      if @method == :* || (request.get? && @method == :get) || (request.post? && @method == :post)
        Boxlet.log(:info, "INFO: Responding: #{@method.upcase} => #{@action}")
        action_response = controller.action(@action)
        response.status = 200
      else
        response.status = 404
        action_response = {format: :html, content: "404 not found"}
      end

      if action_response[:format] == :json
        response.write(action_response[:content].to_json)
      else
        response.write(action_response[:content])
      end

      response.finish
    end

  end
end