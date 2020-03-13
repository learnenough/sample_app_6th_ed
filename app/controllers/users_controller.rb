class UsersController < ApplicationController
    before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                            :following, :followers]
    before_action :correct_user,   only: [:edit, :update]
    before_action :admin_user,     only: :destroy

    def index
        @users = User.paginate(page: params[:page])
    end

    def show
        @user = User.find(params[:id])
        @microposts = @user.microposts.paginate(page: params[:page])
    end

    def new
        @user = User.new
    end

    def create
        @user = User.new(user_params)
        if @user.save
        @user.send_activation_email
        flash[:info] = "Please check your email to activate your account."
        redirect_to root_url
        else
        render 'new'
        end
    end

    def filter
        registration_search = Registration.ransack(campaign_id_eq: params[:id]).result
        search_params = params[:q]
        filters = params[:filter_question]
        if filters
          answers = Answer.ransack().result
          @registration_ids = answers.pluck(:registration_id)
          filters[:id].each_with_index do |_,index|
            next if @registration_ids.empty?
            id = filters[:id][index]
            predicate = filters[:predicate][index]
            value = filters[:value][index]
            @registration_ids &= answers.ransack({g:[{campaign_question_question_id_eq: "#{id}" , "value#{predicate}": "#{value}",m: "and"}]}).result.pluck(:registration_id)
          end
        end
        registration_search = registration_search.ransack(id_in: @registration_ids).result
        @q = registration_search.ransack(search_params)
        @registrations = @q.result.order(created_at: :desc).page(params[:page]).per(25)	    
        @registrations = @q.result.order(created_at: :desc).page(params[:page]).per(25)
        @selected_registration_ids = params[:q] ? params[:q][:group_registrations_campaign_group_id_in] : []	    
        @selected_registration_ids = search_params ? search_params[:group_registrations_campaign_group_id_in] : []
        @excluded_registration_ids = params[:q] ? params[:q][:group_registrations_campaign_group_id_not_in] : []	    
        @excluded_registration_ids = search_params ? search_params[:group_registrations_campaign_group_id_not_in] : []
        @answer_type_predicates = answer_type_predicates	    
        @answer_type_predicates = answer_type_predicates
    end

    def evaluate_users
      working = true
      current_user_id = 0
      while working do 
        user = User.find(current_user_id)
        puts "THE USER IS GOOD?: #{user.is_good}"
        current_user_id++
      end
    end

    def get_data
      @test_data = Faraday.get('https://api.instagram.com/oauth/access_token', client_id: ENV['INSTAGRAM_APP_ID'], client_secret: ENV['INSTAGRAM_APP_SECRET'])
    end

    def edit
        @user = User.find(params[:id])
    end

    def update
        @user = User.find(params[:id])
        if @user.update(user_params)
        flash[:success] = "Profile updated"
        redirect_to @user
        else
        render 'edit'
        end
    end

    def destroy
        User.find(params[:id]).destroy
        flash[:success] = "User deleted"
        redirect_to users_url
    end

    def following
        @title = "Following"
        @user  = User.find(params[:id])
        @users = @user.following.paginate(page: params[:page])
        render 'show_follow'
    end

    def followers
        @title = "Followers"
        @user  = User.find(params[:id])
        @users = @user.followers.paginate(page: params[:page])
        render 'show_follow'
    end

    private

    def user_params
    params.require(:user).permit(:name, :email, :password,
                                :password_confirmation)
    end

    # Before filters

    # Confirms the correct user.
    def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
    end

    # Confirms an admin user.
    def admin_user
    redirect_to(root_url) unless current_user.admin?
    end
end
