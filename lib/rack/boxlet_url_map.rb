require "rack"


module Rack
  class BoxletUrlMap < URLMap

    def remap(map)
      @mapping = map.map { |location, app|
        if location.is_a? String
          if location =~ %r{\Ahttps?://(.*?)(/.*)}
            host, location = $1, $2
          else
            host = nil
          end

          unless location[0] == ?/
            raise ArgumentError, "paths need to start with /"
          end

          location = location.chomp('/')
          match = Regexp.new("^#{Regexp.quote(location).gsub('/', '/+')}(.*)", nil, 'n')
        elsif location.is_a? Regexp
          match = location
        else
          raise ArgumentError, "location should be an instance of String or Regexp"
        end

        [host, location, match, app]
      }.sort_by do |(host, location, _, _)|
        [host ? -host.size : INFINITY, (location.is_a?(String) ? -location.size : INFINITY)]
      end

      @mapping
    end

    def call(env)
      path = env["PATH_INFO"]
      script_name = env['SCRIPT_NAME']
      hHost = env['HTTP_HOST']
      sName = env['SERVER_NAME']
      sPort = env['SERVER_PORT']

      @mapping.each do |host, location, match, app|
        unless hHost == host \
            || sName == host \
            || (!host && (hHost == sName || hHost == sName+':'+sPort))
          next
        end

        next unless m = match.match(path.to_s)

        rest = m[1]
        next unless !rest || rest.empty? || rest[0] == ?/

        return app.call(env)
      end

      [404, {"Content-Type" => "text/plain", "X-Cascade" => "pass"}, ["Not Found: #{path}"]]

    ensure
      env['PATH_INFO'] = path
      env['SCRIPT_NAME'] = script_name
    end

  end
end