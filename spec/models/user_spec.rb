require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    expect(create(:user)).to be_valid
  end

  context 'when name is not present' do
    let(:user) {  User.new(email: Faker::Internet.email, password: User.digest('password')) }

    it 'should not be valid' do
      expect(user.valid?).to be false
    end

    it 'should not save' do
      expect(user.save).to be false
    end
  end

  # TODO: Add tests for associations

  # TODO: Add tests for validations

  describe '#send_password_reset_email' do
    # TODO
  end

  describe '#feed' do
    # TODO
  en
end
