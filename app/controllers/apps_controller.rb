# encoding: utf-8
class AppsController < ApiController


	def index
		from_day = Date.strptime(params[:from_day])
		to_day = Date.strptime(params[:to_day])
		@dates = []
		for i in 0..(to_day-from_day).to_i 
			@dates = @dates + [from_day + i]
		end
		@dates.reverse!
		@apps = @dates.map{|day| App.for_day(day)}

		# day = Date.strptime(params[:day])
		# @apps = App.for_day(day)
	end

	def show
		@app = App.find(params[:id])
	end


end
