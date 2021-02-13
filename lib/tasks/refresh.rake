require 'restclient'
require 'json'
require 'couchrest'
require 'couchrest_model'
# require 'pry'

@timestamp = Time.now.strftime('%Y%m%d')

namespace :homes do

  desc "search for homes"
  task :search => :environment do
    RealtorApi.search
  end

end
