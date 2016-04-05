module Boxlet
  module Config

    ARGS  = {
      :environment => {
        :short      => 'E',
        :default    => 'development'
      },
      :path => {
        :short      => 'f',
        :default    => Proc.new { Dir.pwd }
      },
      :port => {
        :short      => 'p',
        :default    => 8077,
        :sanitizer  => Proc.new { |p| p.to_i }
      },
      :host => {
        :short      => 'o',
        :default    => 'localhost'
      },
      :server_type => {
        :short      => 's',
        :default    => 'rack',
        :sanitizer  => Proc.new { |p| p.to_sym }
      },
      :daemonize => {
        :short      => 'd',
        :default    => 'false',
        :sanitizer  => Proc.new { |p| p == true || p == 'true' }
      },
      :debug => {
        :short      => 'D',
        :default    => 'true',
        :sanitizer  => Proc.new { |p| p == true ||  p == 'true' }
      },
      :upload_dir => {
        :short      => 'U',
        :default    => './uploads'
      },
      :tmp_dir => {
        :short      => 'T',
        :default    => './tmp'
      },
      :file_system_root => {
        :short      => 'r',
        :default    => '/'
      },
      :capacity => {
        :short      => 'C',
        :default    => '90%',
        :sanitizer  => Proc.new { |p| (p.to_i.to_s == p) ? p.to_i : p }
      },
      :pid_file => {
        :short      => 'P',
        :default    => Proc.new { Dir.pwd + "/server.pid" }
      },
      :log_file => {
        :short      => 'L',
        :default    => Proc.new { Dir.pwd + "/server.log" }
      },
      :s3 => {
        :default    => { enabled: false }
      }
    }

    def populate_params!(argv, path_to_config)
      @raw_config = load_config_file(path_to_config)
      @raw_params = parse_arguments(argv)

      @config = @raw_params
      @config[:debug] = @raw_config[:debug] || @raw_params[:debug]
    end

    def symbolize_keys(hash)
      hash.inject({}){|result, (key, value)|
        new_key = key.instance_of?(String) ? key.to_sym : key
        new_value = value.instance_of?(Hash) ? symbolize_keys(value) : value

        result[new_key] = new_value
        result
      }
    end

    private

      def parse_arguments(argv)
        params = @raw_config

        ARGS.each_pair do |param_name, param_attrs|
          param_short_name = param_attrs[:short]
          config_value = @raw_config[param_name.to_sym]
          default = param_attrs[:default]
          sanitizer = param_attrs[:sanitizer]

          param_value = argv["--#{param_name}"] ||
                        (param_short_name.nil? ? nil : argv["-#{param_short_name}"]) ||
                        (config_value.nil? ? nil : config_value) ||
                        (default.is_a?(Proc) ? default.call : default)

          param_value = sanitizer.call(param_value) if sanitizer.is_a?(Proc)

          if !param_value.nil?
            params[param_name] = param_value
          end
        end

        params
      end

      def load_config_file(path_to_config)
        begin
          loaded_config = YAML.load_file(path_to_config)
          symbolize_keys(loaded_config)
        rescue
          Boxlet.log(:warn, "Error loading config file!  Using defaults...")
          {}
        end
      end
    end
end
