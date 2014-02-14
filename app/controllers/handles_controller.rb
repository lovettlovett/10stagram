class HandlesController < ApplicationController

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
		@handle = Handle.create(handle: params[:handle], user_id: params[:user_id])
		redirect_to(user_handles_path)
	end

	def show
		@handle = Handle.find_by_id(params[:id])

		#take an instagram handle and return the insta user_id
		@insta_user_id = find_insta_user_id(@handle.handle)

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
		@average_likes_per_photo = ((@total_likes)/10)
		@unique_likers = all_likers(@insta_user_id).uniq.count
		@percentage_of_followers_who_liked = ((@unique_likers)/(@followed_by) * 100).round(2)

		#people you follow
		#@people_you_follow = find_people_you_follow(@insta_user_id)

		render(:show)
	end

	def find_insta_user_id(username)
		client_id = "8d636c456fe14143b2a220b9ab059ea2"
		client_secret = "bfaba04a15f04d37a946d4ae14d6dec9"

		search_url = "https://api.instagram.com/v1/users/search?q=#{username}&client_id=#{client_id}"

		from_instagram = HTTParty.get(search_url)

		insta_user_id = from_instagram["data"][0]["id"]
		return insta_user_id
	end

	def profile_stats(user_id)
		client_id = "8d636c456fe14143b2a220b9ab059ea2"
		client_secret = "bfaba04a15f04d37a946d4ae14d6dec9"

		search_url = "https://api.instagram.com/v1/users/#{user_id}?client_id=#{client_id}"

		from_instagram = HTTParty.get(search_url)
		
		#outputs – {"media"=>201, "followed_by"=>217, "follows"=>138}
		counts = from_instagram["data"]["counts"]
		return counts
	end

	def profile_attributes(user_id)
		client_id = "8d636c456fe14143b2a220b9ab059ea2"
		client_secret = "bfaba04a15f04d37a946d4ae14d6dec9"

		search_url = "https://api.instagram.com/v1/users/#{user_id}?client_id=#{client_id}"

		from_instagram = HTTParty.get(search_url)
		
		#outputs – {"media"=>201, "followed_by"=>217, "follows"=>138}
		data = from_instagram["data"]
		return data
	end

	def find_people_you_follow(user_id)
		client_id = "8d636c456fe14143b2a220b9ab059ea2"
		client_secret = "bfaba04a15f04d37a946d4ae14d6dec9"

		#need to figure out how to deal with pagination
		search_url = "https://api.instagram.com/v1/users/#{user_id}/follows?client_id=#{client_id}&count=100"

		from_instagram = HTTParty.get(search_url)

		number_of_friends = from_instagram["data"].size

		array = []
		i = 0
			while i < number_of_friends
				users_you_follow = from_instagram["data"][i]["username"]
				array.push(users_you_follow)
				i = i + 1
			end

		return array
	end

	def find_insta_user_id(username)
		client_id = "8d636c456fe14143b2a220b9ab059ea2"
		client_secret = "bfaba04a15f04d37a946d4ae14d6dec9"

		search_url = "https://api.instagram.com/v1/users/search?q=#{username}&client_id=#{client_id}"

		from_instagram = HTTParty.get(search_url)

		insta_user_id = from_instagram["data"][0]["id"]
		return insta_user_id
	end

	def friends_hash(user_id)
		#take the usernames of all the people a handle follows and get their profile details

		#this returns usernames array
		people_you_follow = find_people_you_follow(user_id)

		#this returns an array of user_ids
		user_ids = people_you_follow.map do |person|
			find_insta_user_id(person)
		end

		# #return an array of profile stats
		# number_of_photos = user_ids.select do |id| 
		# 	#next if profile_stats(id) == nil
		# 	profile_stats(id)
		# end

		# number_of_photos = number_of_photos.compact!

		return user_ids
	end

	def retrieve_last_10_photos(user_id)
		client_id = "8d636c456fe14143b2a220b9ab059ea2"
		client_secret = "bfaba04a15f04d37a946d4ae14d6dec9"

		search_url = "https://api.instagram.com/v1/users/#{user_id}/media/recent/?client_id=#{client_id}&count=10"

		from_instagram = HTTParty.get(search_url)

		return from_instagram

	end

	def sort_by_frequency
	    histogram = inject(Hash.new(0)) { |hash, x| hash[x] += 1; hash}
	    sort_by { |x| [histogram[x], x] }
	end

	#returns all the users' tagged in the last 10 photos you've taken
	def top_tagged(user_id)
		from_instagram = retrieve_last_10_photos(user_id)

		all_people_you_tag = []
		users_per_photo = []
		i = 0
		while i < 10
			x = 0
			people_per_photo = from_instagram["data"][i]["users_in_photo"].size
			people_you_tag = from_instagram["data"][i]["users_in_photo"]
			while x < people_per_photo
				username = from_instagram["data"][i]["users_in_photo"][x]["user"]["username"]
				array = users_per_photo.push(username)
				x = x + 1
			end
			i = i + 1
		end

		return array
	end

	#return a sum of all likes from the users' last 10 photos
	def likes(user_id)
		from_instagram = retrieve_last_10_photos(user_id)
		number_of_photos = from_instagram["data"].size
		all_likes = Array.new
		i = 0
		while i < number_of_photos
			likes = from_instagram["data"][i]["likes"]["count"]
			all_likes.push(likes)
			i = i + 1
		end

		all_likes = all_likes.reduce(:+)

		return all_likes
	end

	#a method to find all the unique users who have liked one of your photos
	def all_likers(user_id)
		from_instagram = retrieve_last_10_photos(user_id)
		media_ids = []
		i = 0
		while i < 10 
			type = from_instagram["data"][i]["id"]
			media_ids.push(type)
			i = i + 1
		end

		client_id = "8d636c456fe14143b2a220b9ab059ea2"
		client_secret = "bfaba04a15f04d37a946d4ae14d6dec9"


		likers_results = media_ids.map do |media_id|
			search_url = "https://api.instagram.com/v1/media/#{media_id}/likes?client_id=#{client_id}"
			likers = HTTParty.get(search_url)
		end

		all_likers = Array.new
		likers_per_photo = Array.new

		i = 0
		while i < 10
			x = 0
			likes_per_photo = likers_results[i]["data"].size
			while x < likes_per_photo
				each_user_who_likes_photo = likers_results[i]["data"][x]["username"]
				all_likers = likers_per_photo.push(each_user_who_likes_photo)
				x = x + 1
			end
			i = i + 1
		end

		return all_likers
	end

end






