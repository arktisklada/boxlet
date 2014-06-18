# routes = {
#   ["/", :get]                 => :index,
#   ["/auth"]                   => :auth,
#   ["/register_device", :post] => :register_device,
#   ["/notifications", :post]   => :notifications,
#   ["/push_files", :post]      => :push_files,
#   ["/file_list"]              => :file_list,
#   ["/file_info"]              => :file_info
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
      
      pp @params if Boxlet.config[:debug]

      upload_path = Boxlet.config[:upload_path] || './uploads'
      upload_file = @params["file"]
      new_path = File.join(upload_path, upload_file[:filename])
      FileUtils.mv(upload_file[:tempfile].path, new_path)

      if File.exists? File.join(upload_path, upload_file[:filename])
        file = File.open(File.join(upload_path, upload_file[:filename]), 'r')
        asset = {
          filename: upload_file[:filename],
          size: file.size,
          date: file.mtime.to_i,
          asset_path: @params["asset_path"]
        }
        db.collection('assets').insert(asset)
        {response: true}
      else
        {response: false}
      end
    end

    def file_list
      @format = :json

      db.collection('assets').find().to_a
    end

    def file_info
      @format = :json

      asset_path = @params[:asset_path]
      db.collection('assets').find({asset_path: asset_path}).to_a.first
    end


    private

    def db
      Boxlet::Db.connection
    end

  end
end