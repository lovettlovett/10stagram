class PhotoRetriever
  def initialize(user_id)
    @user_id
  end

  def last_10
    search_url = "https://api.instagram.com/v1/users/#{@user_id}/media/recent/?client_id=#{INSTAGRAM_CLIENT_ID}&count=10"

    from_instagram = HTTParty.get(search_url)

    return from_instagram
  end
end