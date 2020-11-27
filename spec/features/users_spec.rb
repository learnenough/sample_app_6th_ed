require 'rails_helper'

RSpec.feature "Users", type: :feature do
  scenario 'visit all users list' do
    user = create(:user, activated: true, activated_at: Time.zone.now)

    visit root_path
    click_link 'Log in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'

    expect(page).to have_content 'Users'
    expect(page).to have_content 'following'
    expect(page).to have_content 'followers'
  end
end
