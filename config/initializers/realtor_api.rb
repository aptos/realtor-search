require 'uri'
require 'net/http'
require 'openssl'
require 'json'
require 'couchrest'
require 'couchrest_model'

require 'pry'
module RealtorApi

  def self.api_request(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri)
    request["x-rapidapi-key"] = ENV["RAPID_KEY"]
    request["x-rapidapi-host"] = 'realtor-com-real-estate.p.rapidapi.com'
    http.request(request)
  end

  def self.search
    search_props = {
      days_on_realtor: 7,
      hide_pending_contingent: true,
      city: 'Carson City',
      state_code: 'NV',
      location: 89703,
      offset: 0,
      limit: 50,
      price_max: 600000,
      baths_min: 2,
      property_type: 'single_family',
      homehome_size_min: 1250
    }
    uri = URI("https://realtor-com-real-estate.p.rapidapi.com/for-sale")

    uri.query = URI.encode_www_form(search_props)
    response = api_request(uri)

    if r = JSON.parse(response.read_body)
      puts "found: #{r['data']['results'].size}"
      r['data']['results'].each do |listing|
        props = listing.select {|k, |[:property_id, :last_update_date, :list_price, :description, :tags, :permalink, :list_date].include? k.to_sym}
        address = listing['location']['address']
        props['address'] = "#{address['line']}, #{address['city']}, #{address['state']} #{address['postal_code']}"
        props['coordinate'] = listing['location']['address']['coordinate']
        props['street_view'] = listing['location']['street_view_url']
        props['price_sqft'] = listing['list_price']/listing['description']['sqft'].round
        props['photo'] = listing['primary_photo']['href']
        puts props['address']

        if v = home_estimate_value(props['property_id'])
          props['current_values'] = v
          if props['current_values']
            ary = []
            props['current_values'].each{|v| ary.push(v['estimate'])}
            props['discount'] = ary.max - props['list_price']
          end
        end

        if @home = Home.by_property_id.key(props['property_id'].to_i).first
          @home.attributes = props
        else
          @home = Home.new(props)
        end
        @home.save
      end

    end
  end

  def self.home_estimate_value(property_id)
    uri = URI("https://realtor-com-real-estate.p.rapidapi.com/for-sale/home-estimate-value")
    search_hash = {
      property_id: property_id
    }
    uri.query = URI.encode_www_form(search_hash)
    response = api_request(uri)

    if r = JSON.parse(response.read_body)
      return r['data']['current_values'] rescue nil
    end
  end

end
