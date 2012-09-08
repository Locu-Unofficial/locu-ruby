require 'spec_helper'

describe Locu::Venue do

  let(:locu) { Locu::Base.new 'SPEC_API_KEY' }

  describe '#find' do

    describe 'a single valid venue id' do

      describe 'with a menu' do

        let(:venue_id) { '9cd2508687bbb3ff6a49' }

        it 'should return a Venue with a menu' do
          stub_request(:get, "http://api.locu.com/v1_0/venue/9cd2508687bbb3ff6a49/?api_key=SPEC_API_KEY&format=json").to_return(:body => <<-BODY)
          {
            "meta": {
              "cache-expiry": 3600
            },
            "not_found": [],
            "objects": [
              {
                "country": "United States",
                "has_menu": true,
                "id": "9cd2508687bbb3ff6a49",
                "last_updated": "2012-07-20T13:59:15.819543",
                "lat": 33.455863,
                "locality": "Phoenix",
                "long": -112.072167,
                "menus": [
                  {"menu_name": "Menu", "sections": [
                    {"section_name": "Breakfast Fare", "subsections": [
                      {"subsection_name": "", "contents": [
                        {"text": "Served Saturdays, Sundays 8 a.m.- 1 p.m.", "type": "SECTION_TEXT"},
                        {"description": "Three fried eggs", "name": "A breakfast", "option_groups": [], "price": "10.95", "type": "ITEM"},
                        {"description": "Three eggs and hash browns, served with toast and jelly.", "name": "Eggs Your Way", "option_groups": [
                          {"options": [
                            {"name": "Bacon", "price": "+1.50"},
                            {"name": "Sausage","price": "+1.50"}
                          ] ,"text": "Meat", "type": "OPTION_ADD"}
                          ], "price": "7.25", "type": "ITEM"}
                      ]}
                    ]}
                  ]}
                ],
                "name": "Frank Murray's Turf Irish Pub",
                "open_hours": {
                    "Friday": [],
                    "Monday": [],
                    "Saturday": [],
                    "Sunday": [],
                    "Thursday": [],
                    "Tuesday": [],
                    "Wednesday": []
                },
                "postal_code": "85004",
                "region": "AZ",
                "resource_uri": "/v1_0/venue/9cd2508687bbb3ff6a49/",
                "street_address": "705 North 1st St.",
                "website_url": "http://turfirishpub.com/"
              }
            ]
          }
          BODY

          venue = locu.venues.find(venue_id)
          venue.should be_kind_of Locu::Venue

          venue.id.should eql venue_id
          venue.name.should eql "Frank Murray's Turf Irish Pub"
          venue.website_url.should eql 'http://turfirishpub.com/'
          venue.has_menu?.should be_true
          venue.should have(1).menus
          venue.last_updated.should eql DateTime.parse('2012-07-20T13:59:15.819543')
          venue.resource_uri.should eql '/v1_0/venue/9cd2508687bbb3ff6a49/'
          venue.street_address.should eql '705 North 1st St.'
          venue.locality.should eql 'Phoenix'
          venue.region.should eql 'AZ'
          venue.postal_code.should eql '85004'
          venue.country.should eql 'United States'
          venue.lat.should eql 33.455863
          venue.long.should eql(-112.072167)

          menu = venue.menus.first
          menu.should be_kind_of Locu::Menu
          menu.name.should eql 'Menu'
          menu.should have(1).sections
          section = menu.sections.first
          section.should be_kind_of Locu::MenuSection
          section.name.should eql 'Breakfast Fare'
          section.should have(1).subsections
          subsection = section.subsections.first
          subsection.should be_kind_of Locu::MenuSubsection
          subsection.name.should be_empty
          subsection.should have(1).texts
          subsection.texts.first.should eql 'Served Saturdays, Sundays 8 a.m.- 1 p.m.'
          subsection.should have(2).items
          item_1 = subsection.items.first
          item_1.should be_kind_of Locu::MenuItem
          item_1.description.should eql 'Three fried eggs'
          item_1.name.should eql 'A breakfast'
          item_1.option_groups.should be_empty
          item_1.price.should eql 10.95
          item_2 = subsection.items.last
          item_2.should have(1).option_groups
          option_group = item_2.option_groups.first
          option_group.should be_kind_of Locu::MenuOptionGroup
          option_group.text.should eql 'Meat'
          option_group.type.should eql :option_add
          option_group.should have(2).options
          option_group.options.first.should be_kind_of Locu::MenuOption
          option_group.options.first.name.should eql 'Bacon'
          option_group.options.first.price.should eql 1.50
          option_group.options.last.name.should eql 'Sausage'
          option_group.options.last.price.should eql 1.50
        end

      end

      describe 'without a menu' do
        let(:venue_id) { 'eb5f4e0484ed1947e31a' }

        it 'should return a Venue without a menu' do
          stub_request(:get, "http://api.locu.com/v1_0/venue/eb5f4e0484ed1947e31a/?api_key=SPEC_API_KEY&format=json").to_return(:body => <<-BODY)
          {
            "meta": {
              "cache-expiry": 3600
            },
            "not_found": [],
            "objects": [
              {
                "country": "United States",
                "has_menu": false,
                "id": "eb5f4e0484ed1947e31a",
                "last_updated": "2012-05-29T04:32:50.815761",
                "lat": 33.577686,
                "locality": "Lubbock",
                "long": -101.858613,
                "menus": [],
                "name": "Villa's Breakfast & Mexican",
                "open_hours": {
                    "Friday": [],
                    "Monday": [],
                    "Saturday": [],
                    "Sunday": [],
                    "Thursday": [],
                    "Tuesday": [],
                    "Wednesday": []
                },
                "postal_code": "79401",
                "region": "TX",
                "resource_uri": "/v1_0/venue/eb5f4e0484ed1947e31a/",
                "street_address": "1925 19th St.",
                "website_url": ""
              }
            ]
          }
          BODY

          venue = locu.venues.find(venue_id)
          venue.should be_kind_of Locu::Venue

          venue.id.should eql venue_id
          venue.name.should eql "Villa's Breakfast & Mexican"
          venue.website_url.should be_empty
          venue.has_menu?.should be_false
          venue.menus.should be_empty
          venue.last_updated.should eql DateTime.parse('2012-05-29T04:32:50.815761')
          venue.cache_expiry.should eql 3600
          venue.resource_uri.should eql '/v1_0/venue/eb5f4e0484ed1947e31a/'
          venue.street_address.should eql '1925 19th St.'
          venue.locality.should eql 'Lubbock'
          venue.region.should eql 'TX'
          venue.postal_code.should eql '79401'
          venue.country.should eql 'United States'
          venue.lat.should eql 33.577686
          venue.long.should eql(-101.858613)
          venue.should have(7).open_hours
          ['Friday', 'Monday', 'Thursday', 'Tuesday', 'Wednesday', 'Saturday', 'Sunday'].each do |dow|
            venue.open_hours[dow].should be_empty
          end
        end

      end

      describe 'with a nil last_updated' do
        let(:venue_id) { 'b81a229014d67cca4dd8' }

        it 'should return a Venue' do
          stub_request(:get, "http://api.locu.com/v1_0/venue/b81a229014d67cca4dd8/?api_key=SPEC_API_KEY&format=json").to_return(:body => <<-BODY)
          {
            "meta": {
                "cache-expiry": 3600
            },
            "not_found": [],
            "objects": [
            {
              "categories": "[]",
              "country": "United States",
              "cuisines": "[]",
              "facebook_url": "",
              "factual_id": "0ec844a5-e4ce-4c17-84d3-701cbadf791a",
              "has_menu": false,
              "id": "b81a229014d67cca4dd8",
              "last_updated": null,
              "lat": 39.960797,
              "locality": "Camden",
              "long": -75.08472,
              "menus": [],
              "name": "Frank's",
              "open_hours": {
                  "Friday": [],
                  "Monday": [],
                  "Saturday": [],
                  "Sunday": [],
                  "Thursday": [],
                  "Tuesday": [],
                  "Wednesday": []
              },
              "postal_code": "08105",
              "redirected_from": null,
              "region": "NJ",
              "resource_uri": "/v1_0/venue/b81a229014d67cca4dd8/",
              "similar_venues": null,
              "street_address": "3300 River Rd.",
              "twitter_id": "",
              "website_url": "http://"
            }
            ]
          }
          BODY

          venue = locu.venues.find(venue_id)
          venue.should be_kind_of Locu::Venue
          venue.last_updated.should be_nil
        end

      end

      describe 'with opening hours' do

        let(:venue_id) { '9cd2508687bbb3ff6a49' }

        it 'should return a Venue with opening hours' do
          stub_request(:get, "http://api.locu.com/v1_0/venue/9cd2508687bbb3ff6a49/?api_key=SPEC_API_KEY&format=json").to_return(:body => <<-BODY)
          {
              "meta": {
                  "cache-expiry": 3600
              },
              "not_found": [],
              "objects": [
                  {
                      "categories": "['restaurant']",
                      "country": "United States",
                      "cuisines": "['steakhouse / grill']",
                      "facebook_url": "http://www.facebook.com/LeesDeli",
                      "factual_id": "341ffb86-d693-4f9c-ac32-f4105a78f56d",
                      "has_menu": true,
                      "id": "f120ee0d55549c36fdd7",
                      "last_updated": "2012-09-05T11:48:42",
                      "lat": 37.78529,
                      "locality": "San Francisco",
                      "long": -122.395873,
                      "menus": [],
                      "name": "Lee's Deli",
                      "open_hours": {
                          "Friday": [
                              "06:00:00 - 17:00:00"
                          ],
                          "Monday": [
                              "06:00:00 - 17:00:00"
                          ],
                          "Saturday": [],
                          "Sunday": [],
                          "Thursday": [
                              "06:00:00 - 17:00:00"
                          ],
                          "Tuesday": [
                              "06:00:00 - 17:00:00"
                          ],
                          "Wednesday": [
                              "06:00:00 - 17:00:00"
                          ]
                      },
                      "postal_code": "94107",
                      "redirected_from": null,
                      "region": "CA",
                      "resource_uri": "/v1_0/venue/f120ee0d55549c36fdd7/",
                      "similar_venues": null,
                      "street_address": "303 2nd St.",
                      "twitter_id": "",
                      "website_url": "http://leesdeli.com/"
                  }
              ]
          }
          BODY

          venue = locu.venues.find(venue_id)
          venue.should be_kind_of Locu::Venue

          venue.should have(7).open_hours
          ['Friday', 'Monday', 'Thursday', 'Tuesday', 'Wednesday'].each do |dow|
            venue.open_hours[dow].should have(1).item
            venue.open_hours[dow].first.should eql "06:00:00".."17:00:00"
          end
          ['Saturday', 'Sunday'].each do |dow|
            venue.open_hours[dow].should be_empty
          end

        end

      end
    end

    describe 'an invalid venue id' do

      let(:invalid_venue_id) { 'badbadbad' }

      it 'should return nil' do
        stub_request(:get, "http://api.locu.com/v1_0/venue/badbadbad/?api_key=SPEC_API_KEY&format=json").to_return(:status => 404)
        locu.venues.find(invalid_venue_id).should be_nil
      end

    end

    describe 'multiple venue ids' do

      let(:valid_venue_ids) { ['eb5f4e0484ed1947e31a', '9cd2508687bbb3ff6a49'] }
      let(:invalid_venue_ids) { ['definitelynotvalid'] }

      it 'should return valid venues' do
        stub_request(:get,
          "http://api.locu.com/v1_0/venue/eb5f4e0484ed1947e31a;9cd2508687bbb3ff6a49;definitelynotvalid/?api_key=SPEC_API_KEY&format=json"
          ).to_return(:body => <<-BODY)
          {
            "meta": {
                "cache-expiry": 3600
            },
            "not_found": [
                "definitelynotvalid"
            ],
            "objects": [
            {
              "categories": "['restaurant']",
              "country": "United States",
              "cuisines": "['steakhouse / grill']",
              "facebook_url": "",
              "factual_id": null,
              "has_menu": true,
              "id": "9cd2508687bbb3ff6a49",
              "last_updated": "2012-07-20T13:59:15",
              "lat": 33.455863,
              "locality": "Phoenix",
              "long": -112.072167,
              "menus": [],
              "name": "Frank Murray's Turf Irish Pub",
              "open_hours": {
                  "Friday": [],
                  "Monday": [],
                  "Saturday": [],
                  "Sunday": [],
                  "Thursday": [],
                  "Tuesday": [],
                  "Wednesday": []
              },
              "postal_code": "85004",
              "redirected_from": null,
              "region": "AZ",
              "resource_uri": "/v1_0/venue/9cd2508687bbb3ff6a49/",
              "similar_venues": null,
              "street_address": "705 North 1st St.",
              "twitter_id": "",
              "website_url": "http://turfirishpub.com/"
            },
                {
                    "categories": "[]",
                    "country": "United States",
                    "cuisines": "[]",
                    "facebook_url": "",
                    "factual_id": "7ad7ef72-0767-4985-8bd8-16acfe19d279",
                    "has_menu": false,
                    "id": "eb5f4e0484ed1947e31a",
                    "last_updated": "2012-05-29T04:32:50",
                    "lat": 33.577686,
                    "locality": "Lubbock",
                    "long": -101.858613,
                    "menus": [],
                    "name": "Villa's Breakfast & Mexican",
                    "open_hours": {
                        "Friday": [],
                        "Monday": [],
                        "Saturday": [],
                        "Sunday": [],
                        "Thursday": [],
                        "Tuesday": [],
                        "Wednesday": []
                    },
                    "postal_code": "79401",
                    "redirected_from": null,
                    "region": "TX",
                    "resource_uri": "/v1_0/venue/eb5f4e0484ed1947e31a/",
                    "similar_venues": null,
                    "street_address": "1925 19th St.",
                    "twitter_id": "",
                    "website_url": ""
                }
            ]
          }
        BODY

        venues = locu.venues.find(valid_venue_ids + invalid_venue_ids)
        venues.count.should eql valid_venue_ids.count
        venues.each{ |v| v.should be_kind_of Locu::Venue }
        venues.each{ |v| valid_venue_ids.should include(v.id) }
      end

      describe 'with a nil last_updated' do
        let(:venue_id) { 'b81a229014d67cca4dd8' }

        it 'should return a Venue' do
          stub_request(:get, "http://api.locu.com/v1_0/venue/b81a229014d67cca4dd8/?api_key=SPEC_API_KEY&format=json").to_return(:body => <<-BODY)
          {
            "meta": {
                "cache-expiry": 3600
            },
            "not_found": [],
            "objects": [
            {
              "categories": "[]",
              "country": "United States",
              "cuisines": "[]",
              "facebook_url": "",
              "factual_id": "0ec844a5-e4ce-4c17-84d3-701cbadf791a",
              "has_menu": false,
              "id": "b81a229014d67cca4dd8",
              "last_updated": null,
              "lat": 39.960797,
              "locality": "Camden",
              "long": -75.08472,
              "menus": [],
              "name": "Frank's",
              "open_hours": {
                  "Friday": [],
                  "Monday": [],
                  "Saturday": [],
                  "Sunday": [],
                  "Thursday": [],
                  "Tuesday": [],
                  "Wednesday": []
              },
              "postal_code": "08105",
              "redirected_from": null,
              "region": "NJ",
              "resource_uri": "/v1_0/venue/b81a229014d67cca4dd8/",
              "similar_venues": null,
              "street_address": "3300 River Rd.",
              "twitter_id": "",
              "website_url": "http://"
            }
            ]
          }
          BODY

          venue = locu.venues.find(venue_id)
          venue.should be_kind_of Locu::Venue
          venue.last_updated.should be_nil
        end

      end

    end

  end

  describe '#search' do

    let(:locu) { Locu::Base.new 'SPEC_API_KEY' }

    describe 'with a location' do

      describe 'which is valid' do

        let(:location) { [33.45504, -112.07102] }

        it 'should return some results' do
          stub_request(:get, "api.locu.com/v1_0/venue/search/?location=33.45504,-112.07102&api_key=SPEC_API_KEY&format=json").to_return(:body => <<-BODY)
          {
          "meta": {
            "cache-expiry": 3600,
            "limit": 25,
            "next": null,
            "offset": 0,
            "previous": null,
            "total_count": 2
          },
          "objects": [
            {
              "country": "United States",
              "has_menu": true,
              "id": "8cc455cdf4f61a6e73e2",
              "last_updated": "2012-03-20T04:52:56",
              "lat": 33.455666,
              "locality": "Phoenix",
              "long": -112.072014,
              "name": "The Breadfruit & Rum Bar",
              "postal_code": "85004",
              "region": "AZ",
              "resource_uri": "/v1_0/venue/8cc455cdf4f61a6e73e2/",
              "street_address": "108 East Pierce St.",
              "website_url": "http://www.thebreadfruit.com/"
            },
            {
              "country": "United States",
              "has_menu": true,
              "id": "9cd2508687bbb3ff6a49",
              "last_updated": "2012-07-20T13:59:15",
              "lat": 33.455864,
              "locality": "Phoenix",
              "long": -112.07217,
              "name": "Frank Murray's Turf Irish Pub",
              "postal_code": "85004",
              "region": "AZ",
              "resource_uri": "/v1_0/venue/9cd2508687bbb3ff6a49/",
              "street_address": "705 North 1st St.",
              "website_url": "http://turfirishpub.com/"
            }
          ]
        }
          BODY

          venues = locu.venues.search(location: location)
          meta = venues.meta
          meta.should be_kind_of Locu::VenueSearchMetadata
          meta.cache_expiry.should eql 3600
          meta.limit.should eql 25
          meta.next.should be_nil
          meta.offset.should eql 0
          meta.previous.should be_nil
          meta.total_count.should eql 2

          venues.should have(2).items
          venue_1 = venues.first
          venue_1.should be_kind_of Locu::Venue
          venue_1.name.should eql 'The Breadfruit & Rum Bar'
          venue_1.has_menu.should be_true
          venue_1.menus.should be_empty
        end

      end

    end

  end

end

