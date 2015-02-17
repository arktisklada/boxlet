require 'date'
require 'digest'
require 'thread'
require 'ImageResize'
require 'aws-sdk'

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
      @params = Boxlet.symbolize_keys(request.params)
      Boxlet.log(:info, request.params)

      @format = :html
    end

    def action(action)
      action_response = self.send(action)
      set_user if action =~ /push_files|file_list|file_info/
      
      {format: @format, content: action_response}
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

    #   Boxlet.log(:debug, @params)

    #   uuid = @params[:uuid]
    #   # user = Boxlet::Models.user_model.merge { uuid: uuid }
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
    #   # @user
    #   "notifications"
    # end

    def stats
      @format = :json

      {
        capacity: Boxlet::Util.app_space_capacity,
        usage: Boxlet::Util.app_space_usage,
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

      new_thumb_filename = "#{asset_path_params["id"]}-thumb.#{asset_path_params["ext"]}"
      new_thumb_path = File.join(upload_path, new_thumb_filename)

      if File.exists?(new_path)
        file = File.open(new_path, 'r')
        asset = {
          filename: new_filename,
          size: file.size,
          local_date: file.mtime.to_i,
          thumbnail: new_thumb_filename,
          asset_path: @params[:asset_path],
          asset_date: @params[:asset_date],
          uuid: @params[:uuid]
        }
        db.collection('assets').insert(asset)

        t = Thread.new do
          Image.resize(new_path, new_thumb_path, 150, 150)

          if Boxlet.config[:s3][:enabled]
            Boxlet.log(:debug, 'Uploading to S3...')

            s3 = AWS::S3.new(
              :access_key_id => Boxlet.config[:s3][:access_key_id],
              :secret_access_key => Boxlet.config[:s3][:secret_access_key]
            )
            if s3.buckets[Boxlet.config[:s3][:bucket]]
                .objects["#{@params[:uuid]}/#{new_filename}"]
                .write(:file => new_path) &&
              s3.buckets[Boxlet.config[:s3][:bucket]]
                .objects["#{@params[:uuid]}/#{new_thumb_filename}"]
                .write(:file => new_thumb_path)

              FileUtils.rm(new_path)
              FileUtils.rm(new_thumb_path)
              Boxlet.log(:debug, 'Uploading to S3... Done!')
            else
              Boxlet.log(:debug, 'Uploading to S3... Error!!')
            end
          end
        end

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
      Boxlet::Models.file_model.merge db.collection('assets').find({asset_path: asset_path, uuid: uuid}).to_a.first || {}
    end

    def resync
      upload_dir = user_upload_dir || './uploads'
      db.collection('assets').find().each do |a|
        asset_path = a["uuid"] + "/" + a["filename"]
        if !File.exists? upload_dir + "/" + asset_path
          db.collection('assets').remove({"_id" => a["_id"]})
        end
      end
    end


    private

      def db
        Boxlet::Db.connection
      end

      def set_user
        Boxlet::Models.user_model.merge(db.collection('users').find({uuid: @params[:uuid]}).to_a.first || {})
      end

      def user_upload_dir
        dir_name = @params[:uuid] || ''
        user_upload_dir_name = Boxlet.config[:upload_dir] + "/" + dir_name
        Dir.mkdir(user_upload_dir_name) unless File.exists?(user_upload_dir_name)

        if @params[:uuid]
          dir_shortname = Digest::MD5.hexdigest(dir_name)
          user_upload_dir_shortname = Boxlet.config[:upload_dir] + "/" + dir_shortname

          File.symlink(dir_name, user_upload_dir_shortname) if !File.symlink? user_upload_dir_shortname

          if File.symlink?(user_upload_dir_shortname)
            user_upload_dir_shortname
          else
            user_upload_dir_name
          end
        else
          user_upload_dir_name
        end
      end

      def free_space?
        Boxlet::Util.free_space > 50
      end
  end
end