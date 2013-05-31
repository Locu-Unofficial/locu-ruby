require 'spec_helper'

describe Locu::Venue, vcr: { match_requests_on: [:host] } do
  before { VCR.insert_cassette 'venue', :record => :new_episodes }
  after { VCR.eject_cassette }

  let(:locu) { Locu::Base.new SPEC_API_KEY }

  describe '#find' do
    describe 'a single valid venue id' do
      describe 'with a menu' do
        let(:venue_id) { '9cd2508687bbb3ff6a49' }
        let(:venue) { locu.venues.find(venue_id) }

        describe 'venue attributes' do
          it { venue.should be_kind_of Locu::Venue }
          it { venue.id.should eql venue_id }
          it { venue.name.should eql "The Turf Restaurant and Pub" }
          it { venue.website_url.should eql 'http://theturfpub.com' }
          it { venue.has_menu?.should be_true }
          it { venue.should have(1).menus }
          it { venue.resource_uri.should eql '/v1_0/venue/9cd2508687bbb3ff6a49/' }
          it { venue.street_address.should eql '705 N. 1st St.' }
          it { venue.locality.should eql 'Phoenix' }
          it { venue.region.should eql 'AZ' }
          it { venue.postal_code.should eql '85004' }
          it { venue.country.should eql 'United States' }
          it { venue.lat.should eql 33.455863 }
          it { venue.long.should eql(-112.07243357) }
        end

        describe "menu" do
          let(:menu) { venue.menus.first }

          it { menu.should be_kind_of Locu::Menu }
          it { menu.name.should eql 'Menu' }
          it { menu.should have(10).sections }

          describe 'sections' do
            let(:section) { menu.sections.first }

            it { section.should be_kind_of Locu::MenuSection }
            #it { section.name.should eql "Breakfast Fare " }
            it { section.should have(2).subsections }

            describe 'subsections' do
              let(:subsection) { section.subsections.first }

              it { subsection.should be_kind_of Locu::MenuSubsection }
              it { subsection.name.should be_empty }
              it { subsection.should have(1).texts }
              it { subsection.texts.first.should eql 'Served Saturdays, Sundays 8 a.m.- 1 p.m.' }
              it { subsection.should have(6).items }

              describe 'items' do
                describe 'item 1' do
                  let(:item_1) { subsection.items.first }

                  it { item_1.should be_kind_of Locu::MenuItem }
                  it { item_1.description.should eql 'Three fried eggs, bacon and sausages, fried tomato, roasted potatoes and black and white pudding, served with homemade Irish soda bread and butter.' }
                  it { item_1.name.should eql 'Traditional Irish Breakfast' }
                  it { item_1.option_groups.should be_empty }
                  it { item_1.price.should eql 10.95 }
                end

                describe 'item 2' do
                  let(:item_2) { subsection.items.last }

                  it { item_2.should have(0).option_groups }
                end
              end
            end
          end
        end
      end

      describe 'without a menu' do
        let(:venue_id) { 'eb5f4e0484ed1947e31a' }
        let(:venue) { locu.venues.find(venue_id) }

        describe 'Venue' do
          it { venue.should be_kind_of Locu::Venue }
          it { venue.id.should eql venue_id }
          it { venue.name.should eql "Villa's Breakfast & Mexican" }
          it { venue.website_url.should be_empty }
          it { venue.has_menu?.should be_false }
          it { venue.menus.nil?.should be_true }
          it { venue.cache_expiry.should eql 3600 }
          it { venue.resource_uri.should eql '/v1_0/venue/eb5f4e0484ed1947e31a/' }
          it { venue.street_address.should eql '1925 19th St.' }
          it { venue.locality.should eql 'Lubbock' }
          it { venue.region.should eql 'TX' }
          it { venue.postal_code.should eql '79401' }
          it { venue.country.should eql 'United States' }
          it { venue.lat.should eql 33.577686 }
          it { venue.long.should eql(-101.858613) }
          it { venue.should have(7).open_hours }

          ['Friday', 'Monday', 'Thursday', 'Tuesday', 'Wednesday', 'Saturday', 'Sunday'].each do |dow|
            it { venue.open_hours[dow].should be_empty }
          end
        end
      end

      describe 'with opening hours' do
        let(:venue_id) { '9cd2508687bbb3ff6a49' }
        let(:venue) { locu.venues.find(venue_id) }

        describe 'venue opening hours' do
          it { venue.should be_kind_of Locu::Venue }

          it { venue.should have(7).open_hours }
          ['Friday', 'Monday', 'Thursday', 'Tuesday', 'Wednesday'].each do |dow|
            #it { venue.open_hours[dow].should have(1).item }
            #it { venue.open_hours[dow].first.should eql "06:00:00".."17:00:00" }
          end
          ['Saturday', 'Sunday'].each do |dow|
            it { venue.open_hours[dow].should be_empty }
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

        it 'should return some results' do
          venues = locu.venues.search(location: location)
          meta = venues.meta
          meta.should be_kind_of Locu::VenueSearchMetadata
          meta.cache_expiry.should eql 3600
          meta.limit.should eql 25
          meta.next.should be_nil
          meta.previous.should be_nil

          venues.should have(25).items
          venue_1 = venues.first
          venue_1.should be_kind_of Locu::Venue
          venue_1.name.should eql 'The Breadfruit'
          venue_1.has_menu.should be_true
          venue_1.menus.nil?.should be_true
        end
      end
    end
  end

  describe '.to_hash' do
    let(:venue_id) { '9cd2508687bbb3ff6a49' }
    let(:venue) { locu.venues.find(venue_id) }

    it { venue.to_hash.should be_a Hash }

    describe 'hash contents' do
      let(:hash_contents) { venue.to_hash }

      it { hash_contents["id"].should == '9cd2508687bbb3ff6a49' }
      it { hash_contents["name"].should == 'The Turf Restaurant and Pub' }
      it { hash_contents["website_url"].should == 'http://theturfpub.com' }
      it { hash_contents["has_menu"].should == true }
      it { hash_contents["resource_uri"].should == '/v1_0/venue/9cd2508687bbb3ff6a49/' }
      it { hash_contents["street_address"].should == '705 N. 1st St.' }
      it { hash_contents["locality"].should == 'Phoenix' }
      it { hash_contents["region"].should == 'AZ' }
      it { hash_contents["postal_code"].should == '85004' }
      it { hash_contents["country"].should == 'United States' }
      it { hash_contents["lat"].should == 33.455863 }
      it { hash_contents["long"].should == -112.07243357 }

      it { hash_contents["menus"].should be_a Array }
      it { hash_contents["menus"].first.should be_a Hash }
    end
  end

  describe '.menu_to_hash' do
    let(:venue_id) { '9cd2508687bbb3ff6a49' }
    let(:venue) { locu.venues.find(venue_id) }
    let(:menu) { venue.menu }

    describe 'hashed menu' do
      let(:hashed_menu) { venue.menu_to_hash(venue.menus.first) }

      it { hashed_menu.should be_a Hash }
    end
  end
end

