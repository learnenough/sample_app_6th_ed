require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe '#new' do
    it 'returns a 200 response' do
      get :new
      expect(response.status).to eq 200
    end
  end
end
