class Garage < ActiveRecord::Base
  belongs_to :province
  has_many :carparks
  has_many :photos, as: :photoble

  validates_uniqueness_of :phone
  validates :phone, :postal_code, :province, :city, :address, :latitude, :longitude, :presence => true
  validates_numericality_of :postal_code, :latitude, :longitude
  validates_format_of :postal_code, :with => /\d{5}/i, message: I18n.t('activerecord.errors.models.user.invalid')
  validates_length_of :city, maximum: 50
  validates_length_of :address, maximum: 255

  def self.between(lat1,lng1,lat2,lng2)
    where(['Contains(linestringfromwkb(linestring(Point(?,?),Point(?,?),Point(?,?),Point(?,?))), Point(latitude, longitude)) = 1',lat1, lng1, lat1, lng2, lat2, lng1, lat2, lng2])
  end
end
