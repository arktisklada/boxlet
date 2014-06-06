require "json"


module Boxlet
  class Controller
    attr_accessor :request, :format

    def initialize(request)
      @request = request
      @format = :html
    end

    def action(action)
      action_response = self.send(action)
      return {format: @format, content: action_response}
    end

    # actions

    def index
      '<html><body><form action="/push_files" method="post" type="multipart"><input type="file" name="file"><input type="submit"></form>'
    end

    def path
      @format = :json
      "auth"
    end

    def push_files
      @format = :json
    end

  end
end