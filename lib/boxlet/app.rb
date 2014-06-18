#require "rack/boxlet_url_builder"
require "rack/request"
require "rack/response"
require "rack/file_upload"
require "boxlet/db"
require "boxlet/app/router"


module Boxlet
  class App

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

  end
end