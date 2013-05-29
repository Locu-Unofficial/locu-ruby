# Locu

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'locu'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install locu

## Usage
Create a config/initializer/locu.rb file with the following:
    
    LOCU = Locu::Base.new 'YOUR API KEY HERE'

Find a venue:
    
    LOCU.venues.find('9cd2508687bbb3ff6a49')

Search for a venue:
    
    LOCU.venues.search(name: 'farm:table')

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Running specs:
Create a spec/api_key.rb file.  Add the following to it:
    
    SPEC_API_KEY = "YOUR LOCU API KEY"

Run your tests
    
    $ rspec spec