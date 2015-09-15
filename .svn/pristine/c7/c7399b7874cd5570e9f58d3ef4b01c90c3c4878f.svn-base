class MakePhotoPolymorphic < ActiveRecord::Migration
  def self.up
    remove_foreign_key :photos, :garages
    remove_reference :photos, :garage, index: true

    add_reference :photos, :photoble, polymorphic: true, index: true
  end

  def self.down
    remove_reference :photos, :photoble

    add_reference :photos, :garage
  end
end
