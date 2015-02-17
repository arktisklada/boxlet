require "sys/filesystem"
#require "rack/boxlet_url_builder"
require "rack/request"
require "rack/response"
require "rack/file_upload"
require "boxlet/db"
require "boxlet/app/router"
require "boxlet/app/models"


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
        ["/resync", :get]           => :resync
      }
    end

    def bind
      usage = Boxlet::App.app_space_usage
      capacity = Boxlet::App.app_space_capacity
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
          if Boxlet::App.free_space <= 50
            raise "Not enough free space"
          end
          if Boxlet::App.app_space_usage / Boxlet::App.app_space_capacity >= 0.9
            Boxlet.log(:info, "App is over 90% full")
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

      password = encrypt(password)
      user = Boxlet::Models.user_model.merge({username: username, password: password})
      db = Boxlet::Db.connection
      if db.collection('users').find({username: username}).to_a.first
        raise 'username already exists'
      else
        db.collection('users').insert(user)
      end
    rescue Exception => e
      Boxlet.log(:fatal, "ERROR: #{e}")
    end

    def change_password(args)
      unless username = args['-u']
        raise 'You must specify a username with -u'
      end
      unless old_password = args['--old']
        raise 'You must provide the old password with --old'
      end
      unless new_password = args['--new']
        raise 'You must specify a new password with --new'
      end

      old_password = encrypt(old_password)
      new_password = encrypt(new_password)
      user = Boxlet::Models.user_model.merge({username: username, password: old_password})
      db = Boxlet::Db.connection
      if db.collection('users').find({username: username}).to_a.first
        db.collection('users').update({username: username}, {password: new_password})
      else
        raise 'username does not exist or old password incorrect'
      end
    rescue Exception => e
      Boxlet.log(:fatal, "ERROR: #{e}")
    end


    # App disk space functions

    def self.free_space
      return -1 if Boxlet.config[:s3][:enabled]
      Boxlet::App.app_space_capacity - Boxlet::App.app_space_usage
    end

    def self.app_space_capacity
      return -1 if Boxlet.config[:s3][:enabled]
      drive_free_space = Boxlet::App.drive_free_space
      if Boxlet.config[:capacity].is_a? String
        Boxlet::App.drive_free_space * Boxlet.config[:capacity].to_i / 100
      else
        Boxlet.config[:capacity]
      end
    end

    def self.app_space_usage
      raise RuntimeError, "#{Boxlet.config[:upload_dir]} is not a directory" unless File.directory?(Boxlet.config[:upload_dir])
      return -1 if Boxlet.config[:s3][:enabled]

      total_size = 0
      Dir["#{Boxlet.config[:upload_dir]}/**/*"].each do |f|
        total_size += File.size(f) if File.file?(f) && File.size?(f)
      end
      total_size / 1000000 # / 1048576 # to megabytes
    rescue Exception => e
      Boxlet.log(:fatal, "ERROR: #{e}")
    end

    # Drive disk space functions

    def self.drive_free_space
      stat = Filesystem.stat(Boxlet.config[:file_system_root])
      (stat.block_size * stat.blocks_available).to_mb
    end

    def self.drive_capacity
      stat = Filesystem.stat(Boxlet.config[:file_system_root])
      (stat.block_size * stat.blocks).to_mb
    end


    private

      def encrypt(string)
        (Digest::SHA256.new << string).to_s
      end

  end
end