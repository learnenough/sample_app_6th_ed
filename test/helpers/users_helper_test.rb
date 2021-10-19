require 'test_helper'

class UsersHelperTest < ActionView::TestCase
  test "gravatar_url generates url" do
    ::Digest::MD5.expects(:hexdigest).returns('abc')
    user = User.new
    user.email = 'user@gmail.com'
    url = Class.new.extend(::UsersHelper).gravatar_url(user, 80)
    assert_equal 'https://secure.gravatar.com/avatar/abc?s=80', url
  end
end
