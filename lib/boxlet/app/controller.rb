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
      @params = Boxlet.symbolize_keys request.params
      pp request.params

      @format = :html
    end

    def action(action)
      action_response = self.send(action)
      set_user if action =~ /push_files|file_list|file_info/
      
      return {format: @format, content: action_response}
    end


    # actions

    def index
      '<html><body><form action="/push_files" method="post" enctype="multipart/form-data">UUID:<input type="text" name="uuid"><br><input type="file" name="file"><input type="submit"></form>'
    end

    # def auth
    #   @format = :json
    #   "auth"
    # end

    # def register_device
    #   @format = :json

    #   pp @params if Boxlet.config[:debug]

    #   uuid = @params[:uuid]
    #   # user = user_model.merge { uuid: uuid }
    #   if db.collection('users').insert(user)
    #     {response: true}
    #   else
    #     {response: false}
    #   end
    # end

    # def notifications
    #   @format = :json

    #   uuid = @params[:uuid]
    #   notifications = @params[:notifications]
    #   pp uuid
    #   # @user
    #   "notifications"
    # end

    def stats
      @format = :json

      {
        capacity: Boxlet::App.app_space_capacity,
        usage: Boxlet::App.app_space_usage,
        free_space: free_space?
      }
    end

    def push_files
      @format = :json
      
      upload_path = user_upload_dir || './uploads'
      upload_file = @params[:file]
      asset_path = @params[:asset_path]
      asset_path_params = Rack::Utils.parse_nested_query(asset_path[asset_path.index('?') + 1..-1])

      new_filename = "#{asset_path_params["id"]}.#{asset_path_params["ext"]}"
      new_path = File.join(upload_path, new_filename)
      FileUtils.mv(upload_file[:tempfile].path, new_path)

      if File.exists? new_path
        file = File.open(new_path, 'r')
        asset = {
          filename: upload_file[:filename],
          size: file.size,
          date: file.mtime.to_i,
          asset_path: @params[:asset_path],
          uuid: @params[:uuid]
        }
        db.collection('assets').insert(asset)
        {response: true}
      else
        {response: false}
      end
    end

    def file_list
      @format = :json

      uuid = @params[:uuid]
      db.collection('assets').find({uuid: uuid}).to_a
    end

    def file_info
      @format = :json

      uuid = @params[:uuid]
      asset_path = @params[:asset_path]
      file_model.merge db.collection('assets').find({asset_path: asset_path, uuid: uuid}).to_a.first || {}
    end


    private

    def db
      Boxlet::Db.connection
    end

    def set_user
      user_model.merge db.collection('users').find({uuid: @params[:uuid]}).to_a.first || {}
    end

    def user_upload_dir
      user_upload_dir_name = Boxlet.config[:upload_dir] + "/" + (@params[:uuid] || '')
      Dir.mkdir(user_upload_dir_name) unless File.exists?(user_upload_dir_name)
      user_upload_dir_name
    end

    def free_space?
      free_space = Boxlet::App.free_space
      return free_space > 50
    end


    # Models

    def file_model
      {
        filename: '',
        size: 0,
        date: 0,
        asset_path: '',
        uuid: []
      }
    end

    def user_model
      {
        uuid: '',
        notifications: 1,
        last_activity: Time.now
      }
    end

  end
end