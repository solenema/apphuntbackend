require 'nokogiri'
require 'rest_client'
require 'json'
require 'open-uri'
require 'open_uri_redirections'

# Rails.application.load_tasks

PH_BASE_URL = 'https://api.producthunt.com/v1'
PH_GET_POSTS_PATH = '/posts'
PH_CONTENT_TYPE_HEADER = 'application/json'
PH_ACCEPT_HEADER = 'application/json'

desc "This task is called by the Heroku scheduler add-on"
task :collect_apps_from_ph_between, [:day_1, :day_2] => :environment do |t,args|
	days_ago = args.day_1.to_i
	nb_of_products = 0
	nb_of_apps = 0
	while (days_ago >= args.day_2.to_i) do
		puts "Collecting apps #{days_ago} days ago"
		api_url = get_posts_url
		parameters = {days_ago: days_ago}
		header = {content_type: PH_CONTENT_TYPE_HEADER, accept: PH_ACCEPT_HEADER, authorization: authorization_token.to_s}
		json_parameters = parameters.to_json
		json_header= header.to_json
		response = RestClient.get(api_url, {"authorization" => "Bearer #{authorization_token}", :params => {:days_ago => days_ago.to_s}})
		data = JSON.parse(response)
		case response.code
		when 200
			puts "Get Request to the PH API is successful"
			count_posts = data['posts'].count
			puts "There are #{count_posts} products for this day"
			nb_of_products = nb_of_products + count_posts
			data['posts'].each do |post|
				redirect_url = post['redirect_url']	
				begin
					response = open(redirect_url,:allow_redirections => :all)
				rescue StandardError=>e
					puts "Error: #{e} for redirect_url = #{redirect_url}"
				else
					base_url = response.base_uri
					doc = Nokogiri::HTML(response)
					if base_url.to_s.match('itunes.apple')
						
						app = App.find_by_ph_id(post['id'])
						app ||= App.new
						app.name = post['name']
						app.tagline = post['tagline']
						app.day = Date.strptime(post['day'])
						app.ph_id = post['id']
						app.appstore_url = base_url.to_s
						app.appstore_identifier =  base_url.to_s.split('id').last.split('?').first
						if(base_url.to_s)
							app.icon_url = icon_175_for_appstore_url(base_url.to_s) 
						else
							app.icon_url = ""
							puts "no icon_url because no appstore_url"
						end
						app.save
						puts "Save App #{app.name} with appstore URL = #{app.appstore_url} / case 2"
						nb_of_apps = nb_of_apps + 1 
					else
						appstore_url_array = []
						doc.css("a").each do |link|
							href = link['href']
							if href != nil 
								if href.match('itunes.apple') 
									appstore_url_array = (appstore_url_array + [href]).uniq
								end
							end
						end	
						if appstore_url_array.count > 0 
							app = App.find_by_ph_id(post['id'])
							app ||= App.new
							app.name = post['name']
							app.tagline = post['tagline']
							app.day = Date.strptime(post['day'])
							app.ph_id = post['id']
							app.appstore_url_array = appstore_url_array
							app.appstore_url = appstore_url_array[0]
							app.appstore_identifier =  appstore_url_array[0].to_s.split('id').last.split('?').first
							if(appstore_url_array[0])
								app.icon_url = icon_175_for_appstore_url(appstore_url_array[0])
							else
								app.icon_url = ""
								puts "no icon_url because no appstore_url"
							end
							app.save
							nb_of_apps = nb_of_apps + 1 
							puts "Save App #{app.name} with appstore URL = #{app.appstore_url} / case 2"
						end
					end
				end
			end
		else
			response.return!(request, result, &block)

		end
		days_ago -= 1
	end
	puts "Retrieve #{nb_of_apps} apps for #{nb_of_products} products"
end

def icon_175_for_appstore_url(appstore_url)
	begin
		page = open(appstore_url,:allow_redirections => :all)
		if page
			doc = Nokogiri::HTML(page)
			if (doc.css("img.artwork").first)
				app_icon_175 = doc.css("img.artwork").first
				if (app_icon_175["width"] == "175")
					app_icon_175_url = app_icon_175["src-swap"]
				else
				app_icon_175 = doc.css("img.artwork").last
				app_icon_175_url = app_icon_175["src-swap"]
				end
			end
		end
	rescue
		puts "Error whene loading icon for #{appstore_url}"
	end
	return app_icon_175_url
end


def category_for_appstore_url(appstore_url)


end

def https_protocol
	return "https://"
end

def authorization_token
	return "4e3393efe971b9a071b18a61b1f427c6178613a99577e470c70af83715d682da"
end


def get_posts_url
	return api_url.to_s + PH_GET_POSTS_PATH.to_s
end

def api_url
	return PH_BASE_URL.to_s()
end
