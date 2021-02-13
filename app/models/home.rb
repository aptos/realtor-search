class Home < CouchRest::Model::Base
  validates_uniqueness_of :property_id

  property :property_id, Integer
  property :last_update_date, Date
  property :list_price, Integer
  property :price_sqft
  property :description, Hash
  property :tags, Array
  property :photo, String
  property :address, String
  property :street_view, String
  property :current_values, Array
  property :discount, Integer
  property :permalink, String
  property :list_date, Date
  property :coordinate, Hash
  property :archived, TrueClass, default: false
  property :liked, TrueClass, default: false

  timestamps!

  design do
    view :by_property_id
    view :by_discount
  end

end
