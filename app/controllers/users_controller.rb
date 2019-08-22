class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
  end

  def new
  end
end