module Boxlet
  module Arguments

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

    def parse_input(argv)
      params = Hash.new
      
      ARGS.each_pair do |param_name, param_attrs|
        param_shorten_name = param_attrs[:shorten]
        default = param_attrs[:default]
        sanitizer = param_attrs[:sanitizer]
        param_value = argv["--#{param_name}"] ||
                      ( param_shorten_name.nil? ? nil : argv["-#{param_shorten_name}"] ) ||
                      ( default.is_a?(Proc) ? default.call : default )
        ( param_value = sanitizer.call( param_value ) ) if sanitizer.is_a? Proc

        if !param_value.nil?
          params[param_name] = param_value
        end
      end

      params
    end
  end
end