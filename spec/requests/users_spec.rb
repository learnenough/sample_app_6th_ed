require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /users" do
    context 'when user is signned in' do
      before do
        @user = create(:user, activated: true, activated_at: Time.zone.now)
      end

      it 'retunrs a 200 response' do
        sign_in_as(@user)

        get users_path
        expect(response).to have_http_status(200)
      end
    end
    # it "works! (now write some real specs)" do
    #   get users_index_path
    #   expect(response).to have_http_status(200)
    # end
  end
end
