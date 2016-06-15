module Boxlet
  module Handlers
    class Auth
      def initialize(username, password)
        @username = username
        @password = password
        @realm = "Boxlet"
      end

      def authorize(request)
        @auth = Request.new(request.env)

        return unauthorized unless @auth.provided?
        return bad_request unless @auth.basic?

        if valid?(@username, @password)
          headers = {'REMOTE_USER' => @username}

          [200, headers, yield]
        else
          unauthorized
        end
      end

      private

        def challenge
          'Basic realm="%s"' % @realm
        end

        def valid?(username, password)
          @auth.credentials[0] == username &&
            @auth.credentials[1] == password
        end

        def unauthorized(www_authenticate = challenge)
          content_hash = {
            'CONTENT_TYPE' => 'text/plain',
            'CONTENT_LENGTH' => '0',
            'WWW-Authenticate' => www_authenticate.to_s
          }
          return [401, content_hash, []]
        end

        def bad_request
          content_hash = {
            'CONTENT_TYPE' => 'text/plain',
            'CONTENT_LENGTH' => '0'
          }
          return [400, content_hash, []]
        end


        class Request
          def initialize(env)
            @env = env
          end

          def basic?
            "basic" == scheme
          end

          def credentials
            @credentials ||= params.unpack("m*").first.split(/:/, 2)
          end

          def username
            credentials.first
          end

          def provided?
            !authorization_key.nil?
          end

          def parts
            @parts ||= @env[authorization_key].split(' ', 2)
          end

          def scheme
            @scheme ||= parts.first && parts.first.downcase
          end

          def params
            @params ||= parts.last
          end


          private

            AUTHORIZATION_KEYS = ['HTTP_AUTHORIZATION', 'X-HTTP_AUTHORIZATION', 'X_HTTP_AUTHORIZATION']

            def authorization_key
              @authorization_key ||= AUTHORIZATION_KEYS.detect { |key| @env.has_key?(key) }
            end
        end
    end
  end
end