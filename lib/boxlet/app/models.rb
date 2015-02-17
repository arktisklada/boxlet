module Boxlet
  module Models
    def self.file_model
      {
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
        username: '',
        password: '',
        uuid: '',
        notifications: 1,
        last_activity: Time.now
      }
    end

  end
end