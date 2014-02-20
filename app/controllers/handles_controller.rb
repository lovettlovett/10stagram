class HandlesController < ApplicationController
	include InstagramHelper

	def index
		@handles = Handle.where(user_id: params[:user_id])
		render(:index)
	end

	def new
		@user = User.find_by_id(params[:user_id])
		render(:new)
	end

	def create
		@user = User.find_by_id(params[:user_id])
		@user_handle = find_insta_user_id(params[:handle])

		if profile_attributes(@user_handle)
			@handle = Handle.create(handle: params[:handle], user_id: params[:user_id])
			redirect_to(user_handles_path)
		else 
			redirect_to(new_user_handle_path, notice: "Please enter a public Instagram handle.")
		end
	end

	def show
		@handle = Handle.find_by_id(params[:id])

		#take an instagram handle and return the insta user_id
		@insta_user_id = find_insta_user_id(@handle.handle)

		# @insta_user_id = Api.new
		# @insta_user_id = @insta_user_id.find_insta_user_id(username)

		#get basic stats about that user_id: # of photos, # of followers, # of following
		@profile_stats = profile_stats(@insta_user_id)
		@photos = @profile_stats["media"]
		@followed_by = @profile_stats["followed_by"].to_f
		@follows = @profile_stats["follows"]

		#get basic profile stats – i.e. 
		@profile_attributes = profile_attributes(@insta_user_id)
		@bio = @profile_attributes["bio"]
		@website = @profile_attributes["website"]
		@profile_picture = @profile_attributes["profile_picture"]
		@full_name = @profile_attributes["full_name"]
		@top_tagged = top_tagged(@insta_user_id)
		@total_likes = likes(@insta_user_id)
		@total_comments = comments(@insta_user_id)
		@unique_likers = all_likers(@insta_user_id).uniq.count
		@percentage_of_followers_who_liked = ((@unique_likers)/(@followed_by) * 100).round(2)
		@image_urls = last_10_urls(@insta_user_id)
		@filters = filter(@insta_user_id)
		@type = type(@insta_user_id)
		@top_likers = top_likers(@insta_user_id)
		@timeframe = (timeframe(@insta_user_id)).round(2)
		@number_of_photos = number_of_photos(@insta_user_id).to_f
		@average_comments_photo = ((@total_comments)/@number_of_photos)
		@average_likes_per_photo = ((@total_likes)/@number_of_photos)
		@velocity = (@timeframe/@number_of_photos).round(2)

		#people you follow
		#@people_you_follow = find_people_you_follow(@insta_user_id)

		render(:show)
	end

	def destroy
		@user = User.find_by_id(params[:user_id])
		@handle = Handle.find_by_id(params[:id])
		@handle.destroy
		redirect_to user_handles_path(@user)
	end
end
