require "rack/request"
require "rack/response"
require "boxlet/app/controller"


module Boxlet
  class Router

    attr_accessor :method, :action

    # def initialize
      # lambda { |env|
      #   # Boxlet::Controller.route!
      #   # lambda {|*|}
      # }
    # end

    def initialize(method, action)
      @method = method.to_sym
      @action = action.to_sym
    end

    def call(env)
      request = Rack::Request.new(env)
      p request
      response = Rack::Response.new
      controller = Boxlet::Controller.new(request)
      if (request.get? && @method == :get) || (request.post? && @method == :post)
        action_response = controller.action(@action)
      else
        # response_text = "nope"
        raise "404"
      end

      if action_response[:format] == :json
        response.write action_response[:content].to_json
      else
        response.write action_response[:content]
      end

      response.finish
    end


    # LambdaLobster = lambda { |env|
    #   if env["QUERY_STRING"].include?("flip")
    #     lobster = LobsterString.split("\n").
    #       map { |line| line.ljust(42).reverse }.
    #       join("\n")
    #     href = "?"
    #   else
    #     lobster = LobsterString
    #     href = "?flip"
    #   end

    #   content = ["<title>Lobstericious!</title>",
    #              "<pre>", lobster, "</pre>",
    #              "<a href='#{href}'>flip!</a>"]
    #   length = content.inject(0) { |a,e| a+e.size }.to_s
    #   [200, {"Content-Type" => "text/html", "Content-Length" => length}, content]
    # }

  end
end