require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe '#new' do
    it 'returns a 200 response' do
      get :new
      expect(response.status).to eq 200
    end
  end

  describe '#index' do
    context 'when user is not signned in' do
      it 'retunrs a 301 response' do
        get :index
        expect(response.status).to eq 302
      end

      it 'should redirect to sign in page' do
        get :index
        expect(response).to redirect_to login_url
      end
    end

    context 'when user is signned in' do
      before do
        @user = create(:user)
      end

      it 'retunrs a 200 response' do
        sign_in(@user)

        get :index
        expect(response.status).to eq 200
      end
    end

  end
end
