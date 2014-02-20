module InstagramHelper
  def find_insta_user_id(username)
  
    search_url = "https://api.instagram.com/v1/users/search?q=#{username}&client_id=#{INSTAGRAM_CLIENT_ID}"

    from_instagram = HTTParty.get(search_url)

    insta_user_id = from_instagram["data"][0]["id"]
    return insta_user_id
  end

  def profile_stats(user_id)

    search_url = "https://api.instagram.com/v1/users/#{user_id}?client_id=#{INSTAGRAM_CLIENT_ID}"

    from_instagram = HTTParty.get(search_url)
    
    #outputs – {"media"=>201, "followed_by"=>217, "follows"=>138}
    counts = from_instagram["data"]["counts"]
    return counts
  end

  def profile_attributes(user_id)

    search_url = "https://api.instagram.com/v1/users/#{user_id}?client_id=#{INSTAGRAM_CLIENT_ID}"

    from_instagram = HTTParty.get(search_url)
    
    #outputs – {"media"=>201, "followed_by"=>217, "follows"=>138}
    data = from_instagram["data"]
    return data
  end

  def find_people_you_follow(user_id)

    #need to figure out how to deal with pagination
    search_url = "https://api.instagram.com/v1/users/#{user_id}/follows?client_id=#{INSTAGRAM_CLIENT_ID}&count=100"

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
    #   #next if profile_stats(id) == nil
    #   profile_stats(id)
    # end

    # number_of_photos = number_of_photos.compact!

    return user_ids
  end

  def retrieve_last_10_photos(user_id)
    search_url = "https://api.instagram.com/v1/users/#{user_id}/media/recent/?client_id=#{INSTAGRAM_CLIENT_ID}&count=10"

    from_instagram = HTTParty.get(search_url)

    return from_instagram

  end

  def number_of_photos(user_id)
    from_instagram = retrieve_last_10_photos(user_id)
    number_of_photos = from_instagram["data"].size

    return number_of_photos
  end

  def last_10_urls(user_id)
    from_instagram = retrieve_last_10_photos(user_id)
    array_of_image_urls = []
    number_of_photos = from_instagram["data"].size

    i = 0
    while i < number_of_photos
      standard_resolution_url = from_instagram["data"][i]["images"]["standard_resolution"]["url"]
      array_of_image_urls = array_of_image_urls.push(standard_resolution_url)
      i = i + 1
    end

    return array_of_image_urls
  end

  #returns all the users' tagged in the last 10 photos you've taken
  def top_tagged(user_id)
    from_instagram = retrieve_last_10_photos(user_id)

    number_of_photos = from_instagram["data"].size

    all_people_you_tag = []
    users_per_photo = []
    i = 0
    while i < number_of_photos
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

    if array

      b = Hash.new(0)
      array.each do |v|
        b[v] += 1
      end

      sorted_b = b.sort_by {|k, v| v}
      sorted_b = sorted_b.reverse

      sorted_b.map do |k, v|
        puts "#{k}: #{v} tags"
      end

      return sorted_b

    else 
      return "No users tagged"
    end

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

    picture_ids = from_instagram["data"].map { |picture| picture["id"] }
      
    likes = picture_ids.map do |media_id|
      search_url = "https://api.instagram.com/v1/media/#{media_id}/likes?client_id=#{INSTAGRAM_CLIENT_ID}"
      HTTParty.get(search_url)
    end

    likers_usernames = []
    
    likes.each do |photo_likes|
      photo_likes["data"].each do |like|
        likers_usernames << like["username"]
      end
    end

    return likers_usernames
  end

  def top_likers(user_id)
    all_likers = all_likers(user_id)

    b = Hash.new(0)
    all_likers.each do |v|
      b[v] += 1
    end

    sorted_b = b.sort_by {|k, v| v}
    sorted_b = sorted_b.reverse

    return sorted_b

  end

  def filter(user_id)
    from_instagram = retrieve_last_10_photos(user_id)
    number_of_photos = from_instagram["data"].size
    array_of_filters = []
    i = 0

    while i < number_of_photos
      filter = from_instagram["data"][i]["filter"]
      array_of_filters = array_of_filters.push(filter)
      i = i + 1
    end

    b = Hash.new(0)
    array_of_filters.each do |v|
      b[v] += 1
    end

    sorted_b = b.sort_by {|k, v| v}
    sorted_b = sorted_b.reverse

    sorted_b.map do |k, v|
      puts "#{k}: #{v}"
    end

    return sorted_b

  end

  def type(user_id)
    from_instagram = retrieve_last_10_photos(user_id)
    number_of_photos = from_instagram["data"].size

    array_of_types = []
    i = 0

    while i < number_of_photos
      type = from_instagram["data"][i]["type"]
      array_of_types = array_of_types.push(type)
      i = i + 1
    end

    b = Hash.new(0)
    array_of_types.each do |v|
      b[v] += 1
    end

    sorted_b = b.sort_by {|k, v| v}
    sorted_b = sorted_b.reverse

    return sorted_b

  end

  def timeframe(user_id)
    from_instagram = retrieve_last_10_photos(user_id)
    number_of_photos = from_instagram["data"].size.to_i
    #binding.pry
    most_recent_photo = (from_instagram["data"][0]["created_time"]).to_i
    oldest_photo = (from_instagram["data"][(number_of_photos - 1)]["created_time"]).to_i



    most_recent_photo_time = Time.at(most_recent_photo)
    oldest_photo_time = Time.at(oldest_photo)

    difference_in_time = (most_recent_photo_time - oldest_photo_time)

    #time in minutes
    minutes = (difference_in_time/60)

    #time in hours
    hours = (minutes/60)

    #time in days
    days = (hours/24)

    return days


  end

  def comments(user_id)
    from_instagram = retrieve_last_10_photos(user_id)
    number_of_photos = from_instagram["data"].size

    all_comments = Array.new
    i = 0
    while i < number_of_photos
      comments = from_instagram["data"][i]["comments"]["count"]
      all_comments.push(comments)
      i = i + 1
    end

    all_comments = all_comments.reduce(:+)

    return all_comments

  end
end