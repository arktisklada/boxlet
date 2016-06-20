module Boxlet
  class Templates
    def self.method_missing(method, *arguments, &block)
      filename = "#{File.dirname(__FILE__)}/views/#{method}.html"
      if File.exist?(filename)
        File.open(filename).read
      else
        raise "Template file not found for #{method}"
      end
    end
  end
end