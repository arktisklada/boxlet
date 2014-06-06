require "json"

module Boxlet
  class Controller
    attr_accessor :request, :format

    def initialize(request)
      @request = request
      @format = :html
    end

    def index
      "welcome"
    end

    def path
      @format = :json
      "auth"
    end


    def action(action)
      action_response = self.send(action)
      return {format: @format, content: action_response}
    end

  end
end