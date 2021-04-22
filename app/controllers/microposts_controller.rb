class MicropostsController < ApplicationController
  before_action :logged_in_api_user, only: [:index]
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  def index
    @microposts = current_user.microposts
    render json: @microposts
  end

  def create
    @micropost = current_user.microposts.build(micropost_params)
    @micropost.image.attach(params[:micropost][:image])
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    if request.referrer.nil? || request.referrer == microposts_url
      redirect_to root_url
    else
      redirect_to request.referrer
    end
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content, :image)
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      # status: https://stackoverflow.com/questions/10472600/a-redirect-to-from-destroy-action-always-gets-delete-verb-whatever-method-i-dec/20978913
      status = request.delete? ? 303 : 302
      redirect_to root_url, status: status if @micropost.nil?
    end
end
