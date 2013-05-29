require 'spec_helper'

describe Locu::Venue, vcr: { match_requests_on: [:host] } do
  before do
    VCR.insert_cassette 'venue', :record => :new_episodes
  end

  after do
    VCR.eject_cassette
  end

  let(:locu) { Locu::Base.new SPEC_API_KEY }

  describe '#find' do
    describe 'a single valid venue id' do
      describe 'with a menu' do
        let(:venue_id) { '9cd2508687bbb3ff6a49' }

        it 'should return a Venue with a menu' do
          venue = locu.venues.find(venue_id)
          venue.should be_kind_of Locu::Venue

          venue.id.should eql venue_id
          venue.name.should eql "The Turf Restaurant and Pub"
          venue.website_url.should eql 'http://theturfpub.com'
          venue.has_menu?.should be_true
          venue.should have(1).menus
          venue.resource_uri.should eql '/v1_0/venue/9cd2508687bbb3ff6a49/'
          venue.street_address.should eql '705 N. 1st St.'
          venue.locality.should eql 'Phoenix'
          venue.region.should eql 'AZ'
          venue.postal_code.should eql '85004'
          venue.country.should eql 'United States'
          venue.lat.should eql 33.455863
          venue.long.should eql(-112.07243357)

          menu = venue.menus.first
          menu.should be_kind_of Locu::Menu
          menu.name.should eql 'Menu'
          menu.should have(10).sections
          section = menu.sections.first
          section.should be_kind_of Locu::MenuSection
          #section.name.should eql "Breakfast Fare "
          section.should have(2).subsections
          subsection = section.subsections.first
          subsection.should be_kind_of Locu::MenuSubsection
          subsection.name.should be_empty
          subsection.should have(1).texts
          subsection.texts.first.should eql 'Served Saturdays, Sundays 8 a.m.- 1 p.m.'
          subsection.should have(6).items
          item_1 = subsection.items.first
          item_1.should be_kind_of Locu::MenuItem
          item_1.description.should eql 'Three fried eggs, bacon and sausages, fried tomato, roasted potatoes and black and white pudding, served with homemade Irish soda bread and butter.'
          item_1.name.should eql 'Traditional Irish Breakfast'
          item_1.option_groups.should be_empty
          item_1.price.should eql 10.95
          item_2 = subsection.items.last
          item_2.should have(0).option_groups
        end
      end

      describe 'without a menu' do
        let(:venue_id) { 'eb5f4e0484ed1947e31a' }

        it 'should return a Venue without a menu' do
          venue = locu.venues.find(venue_id)
          venue.should be_kind_of Locu::Venue

          venue.id.should eql venue_id
          venue.name.should eql "Villa's Breakfast & Mexican"
          venue.website_url.should be_empty
          venue.has_menu?.should be_false
          venue.menus.should be_empty
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

      describe 'with opening hours' do

        let(:venue_id) { '9cd2508687bbb3ff6a49' }

        it 'should return a Venue with opening hours' do
          venue = locu.venues.find(venue_id)
          venue.should be_kind_of Locu::Venue

          venue.should have(7).open_hours
          ['Friday', 'Monday', 'Thursday', 'Tuesday', 'Wednesday'].each do |dow|
            #venue.open_hours[dow].should have(1).item
            #venue.open_hours[dow].first.should eql "06:00:00".."17:00:00"
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
        locu.venues.find(invalid_venue_id).should be_nil
      end
    end

    describe 'multiple venue ids' do
      let(:valid_venue_ids) { ['eb5f4e0484ed1947e31a', '9cd2508687bbb3ff6a49'] }
      let(:invalid_venue_ids) { ['definitelynotvalid'] }

      it 'should return valid venues' do
        venues = locu.venues.find(valid_venue_ids + invalid_venue_ids)
        venues.count.should eql valid_venue_ids.count
        venues.each{ |v| v.should be_kind_of Locu::Venue }
        venues.each{ |v| valid_venue_ids.should include(v.id) }
      end

      describe 'with a nil last_updated' do
        let(:venue_id) { 'b81a229014d67cca4dd8' }

        it 'should return a Venue' do
          venue = locu.venues.find(venue_id)
          venue.should be_kind_of Locu::Venue
          venue.last_updated.should be_nil
        end
      end
    end
  end

  describe '#search' do
    let(:locu) { Locu::Base.new SPEC_API_KEY }

    describe 'with a location' do
      describe 'which is valid' do
        let(:location) { [33.45504, -112.07102] }
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

