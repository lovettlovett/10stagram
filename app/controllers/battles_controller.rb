class BattlesController < ApplicationController
	include InstagramHelper

	def index
		@user = User.find_by_id(params[:user_id])
		@handle = Handle.find_by_id(params[:handle_id])
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
		@handle = Handle.find_by_id(params[:handle_id])
		

		#user_ids
		@handle_user_id = find_insta_user_id(@handle.handle)
		@versus_user_id = find_insta_user_id(@battle.versus_handle)

		#basic profile_stats
		@handle_stats = profile_stats(@handle_user_id)
		@versus_stats = profile_stats(@versus_user_id)
		@handle_photos = @handle_stats["media"]
		@versus_photos = @versus_stats["media"]
		@handle_followed_by = @handle_stats["followed_by"].to_f
		@versus_followed_by = @versus_stats["followed_by"].to_f
		@handle_follows = @handle_stats["follows"]
		@versus_follows = @versus_stats["follows"]

		#basic profile_attributes
		@handle_profile_attributes = profile_attributes(@handle_user_id)
		@versus_profile_attributes = profile_attributes(@versus_user_id)
		@handle_bio = @handle_profile_attributes["bio"]
		@versus_bio = @versus_profile_attributes["bio"]
		@handle_website = @handle_profile_attributes["website"]
		@versus_website = @versus_profile_attributes["website"]
		@handle_full_name = @handle_profile_attributes["full_name"]
		@versus_full_name = @versus_profile_attributes["full_name"]
		@handle_profile_pic = @handle_profile_attributes["profile_picture"]
		@versus_profile_pic = @versus_profile_attributes["profile_picture"]

		#more advanced stats
		@handle_total_likes = likes(@handle_user_id)
		@versus_total_likes = likes(@versus_user_id)

		@handle_total_comments = comments(@handle_user_id)
		@versus_total_comments = comments(@versus_user_id)

		@handle_number_of_photos = number_of_photos(@handle_user_id).to_f
		@versus_number_of_photos = number_of_photos(@versus_user_id).to_f

		@handle_average_likes_per_photo = ((@handle_total_likes)/@handle_number_of_photos)
		@versus_average_likes_per_photo = ((@versus_total_likes)/@versus_number_of_photos)

		@handle_average_comments_per_photo = ((@handle_total_comments)/@handle_number_of_photos)
		@versus_average_comments_per_photo = ((@versus_total_comments)/@versus_number_of_photos)

		@handle_unique_likers = all_likers(@handle_user_id).uniq.count
		@versus_unique_likers = all_likers(@versus_user_id).uniq.count

		@handle_percentage_of_followers_who_liked = ((@handle_unique_likers)/(@handle_followed_by) * 100).round(2)
		@versus_percentage_of_followers_who_liked = ((@versus_unique_likers)/(@versus_followed_by) * 100).round(2)

		@handle_top_likers = top_likers(@handle_user_id)
		@versus_top_likers = top_likers(@versus_user_id)

		@handle_timeframe = (timeframe(@handle_user_id)).round(2)
		@versus_timeframe = (timeframe(@versus_user_id)).round(2)

		@handle_velocity = (@handle_timeframe/@handle_number_of_photos).round(2)
		@versus_velocity = (@versus_timeframe/@versus_number_of_photos).round(2)

		@handle_image_urls = last_10_urls(@handle_user_id)
		@versus_image_urls = last_10_urls(@versus_user_id)


		render(:show)
	end
end