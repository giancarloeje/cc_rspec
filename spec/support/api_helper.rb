require 'rspec-rails'
require 'factory_bot'

module Requests
  module APIHelpers
    def json
      JSON.parse(response.body)
    end

    def xml
      Nokogiri::XML::Document.parse(response.body)
    end
  end

end