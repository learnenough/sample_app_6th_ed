module UsersHelper

  # Returns the Gravatar for the given user.
  def gravatar_for(user, options = { size: 80 })
    size         = options[:size]
    image_tag(gravatar_url(user, size), alt: user.name, class: "gravatar")
  end

  def gravatar_url(user, size)
    gravatar_id  = Digest::MD5::hexdigest(user.email.downcase)
    "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
  end
end
