class AddAppstoreUrlToApps < ActiveRecord::Migration
  def change
  	add_column :apps, :appstore_url, :string
  end
end
