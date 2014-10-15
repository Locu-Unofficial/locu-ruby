require 'rubygems'
require 'bundler/setup'
require 'webmock/rspec'
require 'vcr'
require 'locu'
require 'api_key'
require 'debugger'
require 'awesome_print'

WebMock.disable_net_connect!

RSpec.configure do |_config|

end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
end
