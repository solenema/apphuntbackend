class ChangeDatatypeOnTaglineFromStringToText < ActiveRecord::Migration
  def change
  	change_column :apps, :tagline, :text, :limit => nil
  end
end
