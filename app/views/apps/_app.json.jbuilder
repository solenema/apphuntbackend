json.cache! app do
	json.id app.id
	json.ph_id app.ph_id
	json.name app.name
	json.day app.day.to_s
	json.tagline app.tagline
	json.appstore_identifier app.appstore_identifier
	json.icon_url app.icon_url
end
	