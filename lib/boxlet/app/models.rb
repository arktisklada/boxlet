module Boxlet
  module Models
    def self.file_model
      {
        _table: 'assets',
        filename: '',
        size: 0,
        local_date: 0,
        thumbnail: '',
        asset_path: '',
        asset_date: '',
        uuid: []
      }
    end

    def self.user_model
      {
        _table: 'users',
        username: '',
        password: '',
        uuid: '',
        notifications: 1,
        last_activity: Time.now
      }
    end

    class Model
      def initialize(properties={})
        @_table = properties.delete(:_table)
      end

      private
        def db
          Boxlet::Db.connection
        end
    end
  end
end