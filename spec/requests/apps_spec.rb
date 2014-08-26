require 'spec_helper'


describe 'GET /v1/apps/:id' do 
	it 'returns list of apps for :days_nb' do
		app = create(:app)
		get '/v1/apps/#{app.id}'
		expect(response).to eq(
			{ 
				"id"=> app.id,
				"ph_id"=> app.ph_id,
				"name"=> app.name,
				"tagline"=> app.tagline,
				"appstore_identifier"=> app.appstore_identifier,
				"icon_url"=> app.icon_url
			}
			)

		end	
	end

