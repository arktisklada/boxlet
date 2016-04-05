require 'rack'
require 'rack/boxlet_url_map'


module Rack
  class BoxletUrlBuilder < Builder

    private

      def generate_map(default_app, mapping)
        mapped = default_app ? {'/' => default_app} : {}
        mapping.each { |r,b| mapped[r] = self.class.new(default_app, &b) }
        BoxletUrlMap.new(mapped)
      end
  end
end
