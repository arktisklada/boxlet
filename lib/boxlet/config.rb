module Boxlet
  module Config

    ARGS  = {
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
      :environment => {
        :short      => 'E',
        :default    => 'development'
      },
      :daemonize => {
        :short      => 'D',
        :default    => false,
        :sanitizer  => Proc.new { |p| p == 'true' }
      },
      :debug => {
        :short      => 'd',
        :default    => false,
        :sanitizer  => Proc.new { |p| p == 'true' }
      },
      :upload_dir => {
        :short      => 'U',
        :default    => './uploads'
      },
      :tmp_dir => {
        :short      => 'T',
        :default    => './tmp'
      }
    }


    def populate_params!(argv, path_to_config=nil)
      @config = load_config_file(path_to_config) unless path_to_config == nil
      @params = parse_arguments(argv).merge(@config)
      if @params[:debug]
        pp @params
      end
    end


    private

    def parse_arguments(argv)
      params = Hash.new

      ARGS.each_pair do |param_name, param_attrs|
        param_short_name = param_attrs[:short]
        config_value = @config[param_name.to_sym]
        default = param_attrs[:default]
        sanitizer = param_attrs[:sanitizer]

        param_value = argv["--#{param_name}"] ||
                      (param_short_name.nil? ? nil : argv["-#{param_short_name}"]) ||
                      (config_value.nil? ? nil : config_value) ||
                      (default.is_a?(Proc) ? default.call : default)

        ( param_value = sanitizer.call( param_value ) ) if sanitizer.is_a? Proc

        if !param_value.nil?
          params[param_name] = param_value
        end
      end

      params
    end

    def load_config_file(path_to_config)
      @config = symbolize_keys(YAML.load_file(path_to_config))
    end

    def symbolize_keys(hash)
      hash.inject({}){|result, (key, value)|
        new_key = key.instance_of?(String) ? key.to_sym : key
        new_value = value.instance_of?(Hash) ? symbolize_keys(value) : value

        result[new_key] = new_value
        result
      }
    end
  end
end