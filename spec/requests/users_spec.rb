require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "#index" do
    context 'when user is signned in' do
      subject { get users_path }

      before do
        @user = create(:user, activated: true, activated_at: Time.zone.now)
      end

      it 'retunrs a 200 response' do
        sign_in_as(@user)
        subject
        expect(response).to have_http_status(200)
      end

      it 'render index template' do
        sign_in_as(@user)
        expect(subject).to render_template(:index)
      end
    end

    context 'when user is not signned in' do
      subject { get users_path }

      it 'retunrs a 302 response' do
        subject
        expect(response).to have_http_status(302)
      end

      it 'render index template' do
        expect(subject).to redirect_to(login_url)
      end
    end
  end

  describe "#edit" do
    context 'when user is signned in' do
      before do
        @user = create(:user, activated: true, activated_at: Time.zone.now)
      end

      subject { get edit_user_path(@user) }

      it 'retunrs a 200 response' do
        sign_in_as(@user)
        subject
        expect(response).to have_http_status(200)
      end

      it 'render edit template' do
        sign_in_as(@user)
        expect(subject).to render_template(:edit)
      end
    end

    context 'when user is not signned in' do
      before do
        @user = create(:user, activated: true, activated_at: Time.zone.now)
      end

      subject { get edit_user_path(@user) }

      it 'returns a 302 response' do
        subject
        expect(response).to have_http_status(302)
      end

      it 'render index template' do
        expect(subject).to redirect_to(login_url)
      end
    end
  end

  descibe '#show' do
    # TODO
  end

  descirbe '#create' do
    # TODO
  end

  describe '#destroy' do
    # TODO
  end

  describe '#following' do
    # TODO
  end
end
