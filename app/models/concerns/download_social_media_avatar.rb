module Download
  def self.SocialMediaIcon url
    file = download_remote_file(url)
    user.avatar.attach(io: file, filename: "user_avatar_#{user.id}.jpg", content_type: "image/jpg")
  end
end
