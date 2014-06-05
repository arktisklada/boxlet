module Boxlet
  class Controller
    attr_accessor :request

    def initialize(request)
      @request = request
    end

    def index
      "welcome"
    end

    def path
      "another path"
    end

  end
end