require "rack/boxlet_url_builder"
require "rack/request"
require "rack/response"
require "boxlet/app/router"


module Boxlet
  class App
    attr_accessor :app, :params

    def initialize(params={})
      @params = params
    end

    def bind
      Rack::Builder.new do
        routes = {
          "/"           => Boxlet::Router.new(:get, :index),
          "/auth"       => Boxlet::Router.new(:get, :path),
          "/push_files" => Boxlet::Router.new(:get, :push_files)
        }

        routes.each do |path, app|
          map path do 
            run app
          end
        end
      end
    end

  end
end