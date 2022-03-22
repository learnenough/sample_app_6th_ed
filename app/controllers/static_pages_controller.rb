class StaticPagesController < ApplicationController

  # @label access.public
  def home
    if logged_in?
      @micropost  = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end
  
  # @label access.public
  def help
  end

  # @label access.public
  def about
  end

  # @label access.public
  def contact
  end
end
