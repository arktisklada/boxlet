require "rack/boxlet_url_builder"
require "rack/request"
require "rack/response"
require "boxlet/router"
# require "boxlet/controller"
require "rack/lobster"


module Boxlet
  class App
    attr_accessor :app, :params, :routes

    def initialize(params={})
      @params = params
    end

    def bind
      Rack::Builder.new do

        routes = {
          "/"       => Boxlet::Router.new(:get, :index),
          "/path"   => Boxlet::Router.new(:get, :path)
        }

        routes.each do |path, app|
          map path do 
            run app
          end
        end

        map "/lobster" do
          use Rack::ShowExceptions
          run Rack::Lobster.new
        end
      end
    end


      # Rack::BoxletUrlBuilder.new do
      #   run Boxlet::Server.new
      # end


      # Boxlet::Server.new.start

      # map '/' do
      #   run Boxlet::Server.new
      # end
      # return


      # return

      # @app = Rack::BoxletUrlBuilder.new do
      #   # use Rack::CommonLogger

      #   index = @params[:index]
      #   path = @params[:path]

      #   use Rack::SimpleEndpoint, '/' => [:get, :post] do |req, res|
      #     'Welcome!'

      #     # res['Content-Type'] = 'application/json'
      #     # %Q({"foo": "#{req[:foo]}"})
      #   end

        # Boxlet::Server.new.start

        # map /^\/.+/ do
        #   run Rack::Directory.new(path)
        # end

        # if !index.nil? && File.exists?(File.join(path, index))
        #   map /^\/$/ do
        #     run Rack::File.new(File.join(path, index))
        #   end
        # end
        
      # end
    # end

  end

end