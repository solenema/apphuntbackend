@dates.each do |date|
	json.set! date.to_s, @apps[@dates.index(date)] do |app|
		json.partial! 'app', app:app
	end
end
