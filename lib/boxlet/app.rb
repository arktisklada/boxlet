require "sys/filesystem"
#require "rack/boxlet_url_builder"
require "rack/request"
require "rack/response"
require "rack/file_upload"
require "boxlet/db"
require "boxlet/app/router"


module Boxlet
  class App

    include Sys

    def self.routes
      routes = {
        ["/", :get]                 => :index,
        ["/auth"]                   => :auth,
        ["/register_device", :post] => :register_device,
        ["/notifications", :post]   => :notifications,
        ["/push_files", :post]      => :push_files,
        ["/file_list"]              => :file_list,
        ["/file_info"]              => :file_info
      }
    end


    def bind
      Rack::Builder.new do
        use Rack::Reloader
        # use Rack::Static, :urls => ["/public"]
        use Rack::FileUpload, :upload_dir => [Boxlet.config[:upload_dir] || APP_ROOT + '/uploads']

        Boxlet::App.routes.each do |route, action|
          map route[0] do
            run Boxlet::Router.new(route[1] || :*, action)
          end
        end
        
      end.to_app
    end


    def setup
      config = Boxlet.config

      # Check for free space
      if Boxlet::App.free_space <= 50
        raise "Not enough free space"
      end

      # Create upload and tmp directories
      upload_dir_name = config[:upload_dir]
      Dir.mkdir(upload_dir_name) unless File.exists?(upload_dir_name)
      tmp_dir_name = config[:tmp_dir]
      Dir.mkdir(tmp_dir_name) unless File.exists?(tmp_dir_name)

      if File.exists?(upload_dir_name) && File.exists?(tmp_dir_name)
        puts "Done."
      else
        puts "Directories don't exist.  Please verify before running."
      end
    end

    def self.free_space
      stat = Filesystem.stat(Boxlet.config[:file_system_root])
      (stat.block_size * stat.blocks_available).to_mb
    end


  end
end