class AddColumnDayToApps < ActiveRecord::Migration
  def change
  	add_column :apps, :day, :date
  end
end
