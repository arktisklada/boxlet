require 'sys/filesystem'

module Boxlet
  module Util
    include Sys

    # Auth methods
    def self.encrypt(string)
      (Digest::SHA256.new << string).to_s
    end

    # App disk space functions
    def self.free_space
      return -1 if Boxlet.config[:s3][:enabled]
      Boxlet::Util.app_space_capacity - Boxlet::Util.app_space_usage
    end

    def self.app_space_capacity
      return -1 if Boxlet.config[:s3][:enabled]
      drive_free_space = Boxlet::Util.drive_free_space
      if Boxlet.config[:capacity].is_a?(String)
        Boxlet::Util.drive_free_space * Boxlet.config[:capacity].to_i / 100
      else
        Boxlet.config[:capacity]
      end
    end

    def self.app_space_usage
      raise RuntimeError, "#{Boxlet.config[:upload_dir]} is not a directory" unless File.directory?(Boxlet.config[:upload_dir])
      return -1 if Boxlet.config[:s3][:enabled]

      total_size = 0
      Dir["#{Boxlet.config[:upload_dir]}/**/*"].each do |f|
        total_size += File.size(f) if File.file?(f) && File.size?(f)
      end
      total_size / 1000000 # / 1048576 # to megabytes
    rescue Exception => e
      Boxlet.log(:fatal, "ERROR: #{e}")
    end

    # Drive disk space functions
    def self.drive_free_space
      stat = Filesystem.stat(Boxlet.config[:file_system_root])
      (stat.block_size * stat.blocks_available).to_mb
    end

    def self.drive_capacity
      stat = Filesystem.stat(Boxlet.config[:file_system_root])
      (stat.block_size * stat.blocks).to_mb
    end

    # Directory paths
    def self.user_upload_dir(uuid)
      dir_name = uuid || ''
      user_upload_dir_name = Boxlet.config[:upload_dir] + "/" + dir_name
      Dir.mkdir(user_upload_dir_name) unless File.exists?(user_upload_dir_name)

      if uuid
        dir_shortname = Digest::MD5.hexdigest(dir_name)
        user_upload_dir_shortname = Boxlet.config[:upload_dir] + "/" + dir_shortname

        File.symlink(dir_name, user_upload_dir_shortname) if !File.symlink? user_upload_dir_shortname

        if File.symlink?(user_upload_dir_shortname)
          user_upload_dir_shortname
        else
          user_upload_dir_name
        end
      else
        user_upload_dir_name
      end
    end

    def self.base_upload_path(uuid)
      if Boxlet.config[:s3][:enabled]
        "https://s3.amazonaws.com/#{Boxlet.config[:s3][:bucket]}/#{uuid}"
      else
        "#{Boxlet.config[:public_url]}/#{Boxlet.config[:upload_dir]}/#{Digest::MD5.hexdigest(uuid)}".gsub('/./', '/')
      end
    end
  end
end
