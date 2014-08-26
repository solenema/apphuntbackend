class AddAttributesToApps < ActiveRecord::Migration
  def change
  	add_column :apps, :appstore_url_array, :string, array:true, default: '{}'
  	add_column :apps, :name, :string
  	add_column :apps, :ph_id, :integer
  	add_column :apps, :tagline, :string
  	add_column :apps, :day, :string
  	add_column :apps, :appstore_identifier, :string 
  	add_column :apps, :icon_url, :string 
  end
end
