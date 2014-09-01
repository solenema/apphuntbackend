class ChangeTypeForAppstoreArray < ActiveRecord::Migration
  def change
  	change_column :apps, :appstore_url_array, :text, array:true, default: '{}'
  end
end
