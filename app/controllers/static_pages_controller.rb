class StaticPagesController < ApplicationController

  # @label public access.public
  def home
    if logged_in?
      @micropost  = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end
  
  # @label public access.public
  def help
  end

  # @label public access.public
  def about
  end

  # @label public access.public
  def contact
  end
end
