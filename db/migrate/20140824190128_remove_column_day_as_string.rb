class RemoveColumnDayAsString < ActiveRecord::Migration
  def change
  	remove_column :apps, :day
  end
end
