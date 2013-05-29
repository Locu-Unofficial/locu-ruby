module Locu
  Venue = Struct.new(:id, :name, :website_url, :has_menu, :menus, :last_updated, :cache_expiry, :resource_uri,
                     :street_address, :locality, :region, :postal_code, :country, :lat, :long, :open_hours) do

    alias has_menu? has_menu

    def self.from_json(body)
      venue = Venue.new
      venue.id = body['id']
      venue.name = body['name']
      venue.website_url = body['website_url']
      venue.has_menu = body['has_menu']
      venue.last_updated = body['last_updated'] ? DateTime.parse(body['last_updated']) : nil
      venue.resource_uri = body['resource_uri']
      venue.street_address = body['street_address']
      venue.locality = body['locality']
      venue.region = body['region']
      venue.postal_code = body['postal_code']
      venue.country = body['country']
      venue.lat = body['lat']
      venue.long = body['long']

      venue.menus = []
      if venue.has_menu? and body['menus']
        venue.menus = body['menus'].collect do |menu|
          sections = menu['sections'].collect do |section|
            subsections = section['subsections'].collect do |subsection|

              subsection_texts = []
              subsection_items = []
              subsection['contents'].each do |subsection_content|
                case subsection_content['type']

                when 'SECTION_TEXT'
                  subsection_texts << subsection_content['text']

                when 'ITEM'
                  option_groups = subsection_content['option_groups'].collect do |option_group|
                    options = option_group['options'].collect do |option|
                      price = option['price'] || 0
                      MenuOption.new option['name'], Float(price)
                    end
                    MenuOptionGroup.new option_group['text'], option_group['type'].downcase.to_sym, options
                  end
                  item = MenuItem.new(subsection_content['name'], subsection_content['description'], option_groups, Float(subsection_content['price']))
                  subsection_items << item
                end

              end
              MenuSubsection.new subsection['subsection_name'], subsection_texts, subsection_items
            end
            MenuSection.new section['section_name'], subsections
          end
          Menu.new menu['menu_name'], sections
        end
      end

      venue.open_hours = {}
      if body['open_hours']
        body['open_hours'].collect do |dow, hours|
          venue.open_hours[dow] = hours.collect do |open_period|
            open, close = open_period.split ' - '
            open..close
          end
        end
      end

      venue
    end

  end

  VenueSearchMetadata = Struct.new :cache_expiry, :limit, :next, :offset, :previous, :total_count do
    def self.from_json(body)
      VenueSearchMetadata.new(body['cache-expiry'], body['limit'], body['next'], body['offset'], body['previous'], body['total_count'])
    end
  end

  module AddMeta
    attr_accessor :meta
  end

  Menu = Struct.new :name, :sections
  MenuSection = Struct.new :name, :subsections
  MenuSubsection = Struct.new :name, :texts, :items
  MenuSectionText = Struct.new :name, :texts, :items
  MenuItem = Struct.new :name, :description, :option_groups, :price
  MenuOptionGroup = Struct.new :text, :type, :options
  MenuOption = Struct.new :name, :price

  class VenueProxy < Base
    def find(ids)
      uri = URI("http://api.locu.com/v1_0/venue/#{ ids.respond_to?(:join) ? ids.join(';') : ids }/")
      uri.query = URI.encode_www_form({ :api_key => @api_key, :format => :json })

      response = Net::HTTP.get_response uri
      return nil unless response.kind_of? Net::HTTPOK

      body = JSON.parse response.body
      return nil unless body['objects'].first

      if ids.kind_of? Array
        venues = body['objects'].collect { |json| Venue.from_json json }
        venues.extend(AddMeta).meta = VenueSearchMetadata.from_json body['meta']
        venues
      else
        venue = Venue.from_json body['objects'].first
        venue.cache_expiry = body['meta']['cache-expiry']
        venue
      end
    end

    def search(conditions)
      raise ArgumentError.new 'search conditions should be passed as a hash' unless conditions.kind_of? Hash

      location, bounds = conditions[:location], conditions[:bounds]
      conditions[:location] = "#{location[0]},#{location[1]}" if location.kind_of? Array
      conditions[:bounds] = "#{bounds[0]}#{bounds[1]}|#{bounds[2]},#{bounds[3]}" if bounds.kind_of? Array

      uri = URI("http://api.locu.com/v1_0/venue/search/")
      uri.query = URI.encode_www_form conditions.merge({ :api_key => @api_key, :format => :json })

      response = Net::HTTP.get_response uri
      body = JSON.parse response.body

      venues = body['objects'].collect { |json| Venue.from_json json }
      venues.extend(AddMeta).meta = VenueSearchMetadata.from_json body['meta']
      venues
    end
  end

end

