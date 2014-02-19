class BattlesController < ApplicationController
	def index
		@battles = Battle.where(handle_id: params[:handle_id])
		render(:index)
	end
end