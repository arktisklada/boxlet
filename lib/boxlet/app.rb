#require "rack/boxlet_url_builder"
require 'rack/request'
require 'rack/response'
require 'rack/file_upload'
require 'boxlet/db'
require 'boxlet/util'
require 'boxlet/app/router'
require 'boxlet/app/models'


module Boxlet
  class App

    include Sys

    def self.routes
      routes = {
        # ["/", :get]                 => :index,
        # ["/auth"]                   => :auth,
        # ["/register_device", :post] => :register_device,
        # ["/notifications", :*]   => :notifications,
        ["/stats", :post]           => :stats,
        ["/push_files", :post]      => :push_files,
        ["/file_list"]              => :file_list,
        ["/file_info"]              => :file_info,
        ["/resync", :get]           => :resync,
        ["/flashback", :post]       => :flashback
      }
    end

    def bind
      usage = Boxlet::Util.app_space_usage
      capacity = Boxlet::Util.app_space_capacity
      Boxlet.log(:info, "INFO: Space Utilization: #{usage}MB / #{capacity}MB (#{(usage.to_f / capacity).round(3)}%)")

      Rack::Builder.new do
        use Rack::Reloader
        # use Rack::FileUpload, :upload_dir => [Boxlet.config[:upload_dir] || APP_ROOT + "/uploads"]
        use Rack::FileUpload, Boxlet.config
        use Rack::Static, :urls => ["/uploads"]

        Boxlet::App.routes.each do |route, action|
          map route[0] do
            run Boxlet::Router.new(route[1] || :*, action)
          end
        end
      end.to_app
    end


    def setup(args)
      begin
        Boxlet.log(:debug, Boxlet.config)
        # Create upload and tmp directories
        upload_dir = Boxlet.config[:upload_dir]
        tmp_dir = Boxlet.config[:tmp_dir]
        if !File.exists?(upload_dir) || !File.exists?(tmp_dir)
          if !File.exists?(upload_dir)
            Boxlet.log(:info, "Upload directory (#{upload_dir}) does not exist.  Creating...")
            Dir.mkdir(upload_dir)
            Boxlet.log(:info, "Upload directory created!")
          end
          if !File.exists?(tmp_dir)
            Boxlet.log(:info, "Temp directory (#{tmp_dir}) does not exist.  Creating...")
            Dir.mkdir(tmp_dir)
            Boxlet.log(:info, "Temp directory created!")
          end
          if File.exists?(upload_dir) && File.exists?(tmp_dir)
            Boxlet.log(:info, "Done creating directories.")
          else
            raise "Error creating directories.  Please check your config and file permissions, and retry."
          end
        end

        # Check for free space
        if !Boxlet.config[:s3][:enabled]
          if Boxlet::Util.free_space <= 50
            raise "Not enough free space"
          end
          if Boxlet::Util.app_space_usage / Boxlet::Util.app_space_capacity >= 0.9
            Boxlet.log(:warn, "App is over 90% full")
          end
        end

        Boxlet.log(:info, "Boxlet setup is done!")
      rescue Exception => e
        Boxlet.log(:fatal, "ERROR: #{e}")
      end
    end


    def add_user(args)
      unless username = args['-u']
        raise 'You must specify a username with -u'
      end
      unless password = args['-p']
        raise 'You must specify a password with -p'
      end

      password = Boxlet::Util.encrypt(password)
      db = Boxlet::Db.connection
      query_params = {username: username, password: password}
      if db.collection('users').find(query_params).count > 0
        raise "Username \"#{username}\" already exists"
      else
        user = Boxlet::Models.user_model.merge({username: username, password: password})
        db.collection('users').insert(user)
        Boxlet.log(:info, "User created successfully")
      end
    rescue Exception => e
      Boxlet.log(:fatal, "ERROR: #{e}")
    end

    def change_password(args)
      unless username = args['-u']
        raise 'You must specify a username with -u'
      end
      unless current_password = args['-p']
        raise 'You must provide the current password with -p'
      end
      unless new_password = args['--new']
        raise 'You must specify a new password with --new'
      end

      current_password = Boxlet::Util.encrypt(current_password)
      new_password = Boxlet::Util.encrypt(new_password)
      query_params = {username: username, password: current_password}
      db = Boxlet::Db.connection
      if db.collection('users').find(query_params).count > 0
        db.collection('users').update({username: username}, {'$set' => {password: new_password}})
        Boxlet.log(:info, "Password updated successfully for \"#{username}\"")
      else
        raise 'Username does not exist or password incorrect'
      end
    rescue Exception => e
      Boxlet.log(:fatal, "ERROR: #{e}")
    end

  end
end