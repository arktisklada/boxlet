require "fileutils"
require "yaml"

require "boxlet/version"
require "boxlet/log"
require "boxlet/tcp_server"


module Boxlet
  
  class Server
    def initialize()
      # Load the config
      @@config = YAML.load_file("config.yml")
      
      if @@config['git_debug'] then
        Grit.debug = true
      end
      
      @server = TcpServer.new
    end
    
    public
    
    def self.config
      return @@config
    end
    
    def run
      @server.start
    end
  end
end
