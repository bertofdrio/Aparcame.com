class Province < ActiveRecord::Base
  has_many :garages

  validates_uniqueness_of :name, :on => :create, :message => 'must be unique'
end
