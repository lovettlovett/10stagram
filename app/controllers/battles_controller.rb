class BattlesController < ApplicationController
	def index
		@battles = Battle.where(handle_id: params[:handle_id])
		render(:index)
	end

	def new
		@user = User.find_by_id(params[:user_id])
		@handle = Handle.find_by_id(params[:handle_id])
		render(:new)
	end

	def create
		@user = User.find_by_id(params[:user_id])
		@handle = Handle.find_by_id(params[:handle_id])
		#@user_handle = find_insta_user_id(params[:battle])
		@battle = Battle.create(versus_handle: params[:versus_handle], handle_id: params[:handle_id])
		redirect_to(user_handle_battles_path)
	end

	def show
		@battle = Battle.find_by_id(params[:id])
		render(:show)
	end
end