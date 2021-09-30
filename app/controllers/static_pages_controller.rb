class StaticPagesController < ApplicationController

  # @label public
  def home
    if logged_in?
      @micropost  = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end
  
  # @label public
  def help
  end

  # @label public
  def about
  end

  # @label public
  def contact
  end
end
