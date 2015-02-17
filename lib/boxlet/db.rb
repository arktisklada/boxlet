require 'mongo'


module Boxlet
  module Db

    extend self
    include Mongo

    attr_accessor :db

    def connection
      @db ||= self.connect
    end

    def connect
      config = Boxlet.config
      db_config = config[:db][config[:environment].to_sym || :development]

      host = db_config[:host] || 'localhost'
      port = db_config[:port] || MongoClient::DEFAULT_PORT
      Boxlet.log(:info, "INFO: Connecting to #{host}:#{port}")
      client  = MongoClient.new(host, port)
      db = client.db(db_config[:db] || 'boxlet_development')
      return db
    end

  end
end