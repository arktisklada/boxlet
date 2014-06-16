# routes = {
#   ["/", :get]                 => :index,
#   ["/auth"]                   => :auth,
#   ["/register_device": :post] => :register_device,
#   ["/notifications": :post]   => :notifications,
#   ["/push_files", :post]      => :push_files,
#   ["/file_list", :get]        => :file_list
# }


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

    def auth
      @format = :json
      "auth"
    end

    def register_device
      "register_device"
    end

    def notifications
      "notifications"
    end

    def push_files
      @format = :json

      upload_path = @params[:upload_path] || './uploads'
      file = @request.params["file"]
      FileUtils.mv file[:tempfile].path, File.join(upload_path, file[:filename])

      File.exists? File.join(upload_path, file[:filename])
    end

    def file_list
      @format = :json

      upload_path = @params[:upload_path] || './uploads'

      Dir.glob(File.join("#{upload_path}/*")).map {|d| d.gsub("#{upload_path}/", '')}
    end

  end
end