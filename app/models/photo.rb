class Photo < ActiveRecord::Base
  belongs_to :photoble, polymorphic: true

  has_attached_file :image, :styles => {:thumb => "100x100>"},
                    :url => "/images/:photoble_type/:photoble_id/:style/:number.jpg"

  validates_attachment :image,
                       :content_type => {:content_type => ["image/jpeg", "image/gif", "image/png"]}

end
