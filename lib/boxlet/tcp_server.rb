require "socket"

class TcpServer

  include Log

  def initialize()
    @listen_ip = Boxlet::Server.config['tcp_listen_ip'] || '127.0.0.1'
    @listen_port = Boxlet::Server.config['tcp_listen_port'] || 11311
    
    @log = get_logger('log/tcp.log', 10, 1024000, Boxlet::Server.config['tcp_debug'] ? Logger::DEBUG : Logger::WARN);
    @log.info("Initializing TCP server on #{@listen_ip}:#{@listen_port}")
    @server = TCPServer.open(@listen_ip, @listen_port)

    # @connections = Hash.new
  end

  def start
    @log.info("Starting TCP server")
    
    # Start a new thread for the TCP server so that it does not block and
    # hold up the rest of the program execution
    # Thread.start() do 
      loop {
        # When a new connection comes in, create a new thread and begin handling
        # requests
        Thread.start(@server.accept) do |client|
          @connections
          @log.info("Client connected!")
          
          # Output welcome messages
          client.puts Time.now.ctime
          client.puts "Welcome to Boxlet!"
          
          # Read input from TCP client
          while line = client.gets
            entry = line.split
            cmd = entry.shift
            
            case cmd
              # Retrieve config value
              when "config_get" then client.puts(Boxlet::Server.config[entry[0]] || "ERROR")
              
              # Halt the server
              when "stop" then
                client.puts "Daemon halting!"
                @log.info("Daemon halting!")
                exit(0)
              
              # Disconnect the client
              when "quit" then
                client.puts "Goodbye!"
                client.close
              else
                client.puts "INVALID"
            end
          end
        end
      }
    # end
  end

end
