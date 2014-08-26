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
task :collect_apps_from_ph => :environment do

	api_url = get_posts_url
	days_ago = 0
	parameters = {days_ago: days_ago}
	header = {content_type: PH_CONTENT_TYPE_HEADER, accept: PH_ACCEPT_HEADER, authorization: authorization_token.to_s}
	json_parameters = parameters.to_json
	json_header= header.to_json
	response = RestClient.get(api_url, {"authorization" => "Bearer #{authorization_token}", :params => {:days_ago => days_ago.to_s}})
	data = JSON.parse(response)
	case response.code
	when 200
		p "it works"
		count_posts = data['posts'].count
		puts "#{count_posts}"
		data['posts'].each do |post|
			redirect_url = post['redirect_url']	
			begin
				response = open(redirect_url,:allow_redirections => :all)
			rescue StandardError=>e
				puts "Error: #{e}"
			else
				base_url = response.base_uri
				doc = Nokogiri::HTML(response)
				if base_url.to_s.match('itunes.apple')
					app = App.find_by_ph_id(post['id'])
					app ||= App.new
					#app.appstore_url = base_url.to_s
					app.name = post['name']
					app.tagline = post['tagline']
					app.day = Date.strptime(post['day'])
					app.ph_id = post['id']
					app.appstore_url = base_url.to_s
					app.icon_url = icon_175_for_appstore_url(base_url.to_s)
					puts "Add App {#{post['name']}}"
					app.save
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
						app.icon_url = icon_175_for_appstore_url(appstore_url_array[0])
						puts "Add App {#{post['name']}}"
						app.save
					end
				end
			end
		end
	else
		response.return!(request, result, &block)

	end

end

def icon_175_for_appstore_url(appstore_url)
	app_icon_175_url = ""
	if(appstore_url) 
		page = open(appstore_url,:allow_redirections => :all)
		doc = Nokogiri::HTML(page)
		if (doc.css("img.artwork").first)
			app_icon_175 = doc.css("img.artwork").first
			if (app_icon_175["src-swap"])
				app_icon_175_url = app_icon_175["src-swap"]
			end
		end
			return app_icon_175_url
		end
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
