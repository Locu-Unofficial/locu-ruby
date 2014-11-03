module Locu
  class Base
    def initialize(api_key)
      @api_key = api_key
    end

    def venues
      VenueProxy.new @api_key
    end
  end
end
