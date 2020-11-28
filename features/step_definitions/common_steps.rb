Given('I am logged in as an activated user') do
  @user = FactoryBot.create(:user, activated: true, activated_at: Time.zone.now)

  visit login_path
  fill_in 'Email', with: @user.email
  fill_in 'Password', with: @user.password
  click_button 'Log in'
end

Then(/^(?:|I )should see "([^"]*)"$/) do |text|
  page.should have_content(text)
end
