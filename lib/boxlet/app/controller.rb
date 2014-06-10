require "json"


module Boxlet
  class Controller
    attr_accessor :request, :format, :params

    def initialize(request)
      @request = request
      @params = request.params
      @format = :html
    end

    def action(action)
      action_response = self.send(action)
      return {format: @format, content: action_response}
    end

    # actions

    def index
      '<html><body><form action="/push_files" method="post" enctype="multipart/form-data"><input type="file" name="file"><input type="submit"></form>'
    end

    def path
      @format = :json
      "auth"
    end

    def push_files
      @format = :json

      upload_path = @params[:upload_path] || './uploads'
      file = @request.params["file"]
      FileUtils.mv file[:tempfile].path, File.join(upload_path, file[:filename])

      File.exists? File.join(upload_path, file[:filename])
    end

  end
end