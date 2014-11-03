module Locu
  Venue = Struct.new(:id, :name, :website_url, :has_menu, :menus, :last_updated, :cache_expiry, :resource_uri,
                     :street_address, :locality, :region, :postal_code, :country, :lat, :long, :open_hours, :phone) do
    ATTRIBUTES = %w(id name website_url has_menu resource_uri street_address locality region postal_code country lat long phone)

    alias_method :has_menu?, :has_menu

    def self.from_json(body)
      venue = Venue.new
      ATTRIBUTES.each { |attribute| venue.send("#{attribute}=", body[attribute]) }

      if venue.has_menu? && body['menus']
        venue.menus = body['menus'].map do |menu|
          sections = menu['sections'].map do |section|
            subsections = section['subsections'].map do |subsection|

              subsection_texts = []
              subsection_items = []
              subsection['contents'].each do |subsection_content|
                case subsection_content['type']

                when 'SECTION_TEXT'
                  subsection_texts << subsection_content['text']

                when 'ITEM'
                  option_groups = subsection_content['option_groups'].map do |option_group|
                    options = option_group['options'].map do |option|
                      price = Money.parse(option['price'])
                      MenuOption.new option['name'], price
                    end
                    MenuOptionGroup.new option_group['text'], option_group['type'].downcase.to_sym, options
                  end

                  price = Money.parse(subsection_content['price'])
                  item = MenuItem.new(subsection_content['name'], subsection_content['description'], option_groups, price)
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
        body['open_hours'].map do |dow, hours|
          venue.open_hours[dow] = hours.map do |open_period|
            open, close = open_period.split ' - '
            open..close
          end
        end
      end
      venue
    end

    def to_hash
      hash = {}
      ATTRIBUTES.each { |attribute| hash[attribute] = send(attribute) }

      if has_menu?
        hash['menus'] = []
        menus.each { |menu| hash['menus'] << menu_to_hash(menu) }
      else
        hash['menus'] = {}
      end

      hash
    end

    def menu_to_hash(menu)
      hash = {}
      menu['sections'].each do |section|
        hash[section.name] = {}
        section['subsections'].each do |subsection|
          hash[section.name][subsection.name] = []
          subsection['items'].each do |item|
            hash[section.name][subsection.name] << item_to_hash(item)
          end
        end
      end
      hash
    end

    def item_to_hash(item)
      item_flat = item.to_h
      item_flat[:price] = item_flat[:price].to_s

      if item.option_groups.size > 0
        item_option_groups = {}
        item.option_groups.each do |option_group|
          item_option_groups[option_group.text] = []
          option_group.options.each do |option|
            option_flat = option.to_h
            option_flat[:price] = option_flat[:price].to_s
            item_option_groups[option_group.text] << option_flat
          end
        end
        item_flat[:option_groups] = item_option_groups
      end
      item_flat
    end
  end

  VenueSearchMetadata = Struct.new :cache_expiry, :limit, :next, :offset, :previous, :total_count do
    def self.from_json(body)
      VenueSearchMetadata.new(body['cache-expiry'], body['limit'],
                              body['next'], body['offset'], body['previous'], body['total_count'])
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
      uri = URI("http://api.locu.com/v2_0/venue/#{ ids.respond_to?(:join) ? ids.join(';') : ids }/")
      uri.query = URI.encode_www_form(api_key: @api_key, format: :json)

      response = Net::HTTP.get_response uri
      return nil unless response.is_a? Net::HTTPOK

      # remove junk from the response
      response.body.gsub!(/^\S*\(/, '') if response.body
      response.body.gsub!(/\)$/, '') if response.body

      body = JSON.parse response.body
      return nil unless body['objects'].first

      if ids.is_a? Array
        venues = body['objects'].map { |json| Venue.from_json json }
        venues.extend(AddMeta).meta = VenueSearchMetadata.from_json body['meta']
        venues
      else
        venue = Venue.from_json body['objects'].first
        venue.cache_expiry = body['meta']['cache-expiry']
        venue
      end
    end

    def find_and_return_menus_json(ids)
      uri = URI("http://api.locu.com/v2_0/venue/#{ ids.respond_to?(:join) ? ids.join(';') : ids }/")
      uri.query = URI.encode_www_form(api_key: @api_key, format: :json)

      response = Net::HTTP.get_response uri
      return nil unless response.is_a? Net::HTTPOK

      # remove junk from the response
      response.body.gsub!(/^\S*\(/, '') if response.body
      response.body.gsub!(/\)$/, '') if response.body

      body = JSON.parse response.body
      return nil unless body['objects'].first

      body['objects'].first['menus']
    end

    def search(conditions)
      fail ArgumentError.new 'search conditions should be passed as a hash' unless conditions.is_a? Hash

      location, bounds = conditions[:location], conditions[:bounds]
      conditions[:location] = "#{location[0]},#{location[1]}" if location.is_a? Array
      conditions[:bounds] = "#{bounds[0]}#{bounds[1]}|#{bounds[2]},#{bounds[3]}" if bounds.is_a? Array

      uri = URI('http://api.locu.com/v2_0/venue/search/')
      uri.query = URI.encode_www_form conditions.merge(api_key: @api_key, format: :json)

      response = Net::HTTP.get_response uri
      body = JSON.parse response.body

      venues = body['objects'].map { |json| Venue.from_json json }
      venues.extend(AddMeta).meta = VenueSearchMetadata.from_json body['meta']
      venues
    end
  end
end
