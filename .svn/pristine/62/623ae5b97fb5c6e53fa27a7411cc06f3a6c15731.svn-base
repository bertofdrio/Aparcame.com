#encoding: utf-8

class CreateProvinces < ActiveRecord::Migration
  def self.up
    create_table :provinces, :force => true do |t|
      t.string :name,   :limit => 50
    end

    spain_provinces = ["Álava","Albacete","Alicante","Almería","Asturias","Ávila","Badajoz","Barcelona","Burgos","Cáceres","Cádiz","Cantabria","Castellón","Ciudad Real","Córdoba","La Coruña","Cuenca","Gerona","Granada","Guadalajara","Guipúzcoa","Huelva","Huesca","Islas Baleares","Jaén","León","Lérida","Lugo","Madrid","Málaga","Murcia","Navarra","Orense","Palencia","Las Palmas","Pontevedra","La Rioja","Salamanca","Segovia","Sevilla","Soria","Tarragona","Santa Cruz de Tenerife","Teruel","Toledo","Valencia","Valladolid","Vizcaya","Zamora","Zaragoza"]
    spain_provinces.each { |sp| Province.create(:name => sp) }
  end

  def self.down
    drop_table :provinces
  end
end
