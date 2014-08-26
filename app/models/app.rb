class App < ActiveRecord::Base

require 'nokogiri'
require 'rest_client'
require 'json'
require 'open-uri'
require 'open_uri_redirections'

validates :ph_id, :uniqueness => true

scope :for_day_between, -> (from_day,to_day) {
where(day: from_day..to_day)
}
scope :for_day, ->(day) {where(day: day)}


def self.collect_app_icons_for_appstore_url(appstore_url)
	page = open(appstore_url,:allow_redirections => :all)
	doc = Nokogiri::HTML(page)
	app_icon_175 = doc.css("img.artwork").first
	app_icon_175_url = app_icon_175["src-swap"]
	return app_icon_175_url
end


end
