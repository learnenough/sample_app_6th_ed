require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe '#new' do
    it 'returns a 200 response' do
      get 'new'
      expect(response).to be_success
    end
  end
end
