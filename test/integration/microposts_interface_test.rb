require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  class QueryCountHandler
    attr_reader :count

    def initialize
      @count = 0
    end

    def call(name, started, finished, unique_id, payload)
      # puts payload[:sql]
      @count += 1
    end
  end

  def setup
    @user = users(:michael)
  end

  def count_sql(message)
    warn "Counting SQL queries for: #{message}"

    count_handler = QueryCountHandler.new
    ActiveSupport::Notifications.subscribe 'sql.active_record', count_handler

    yield

    warn "Observed #{count_handler.count} SQL queries"
    ActiveSupport::Notifications.unsubscribe count_handler
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    assert_select 'input[type=file]'
    # Invalid submission
    post microposts_path, params: { micropost: { content: "" } }
    assert_select 'div#error_explanation'
    assert_select 'a[href=?]', '/?page=2'  # Correct pagination link
    # Valid submission
    content = "This micropost really ties the room together"
    image = fixture_file_upload('kitten.jpg', 'image/jpeg')

    assert_difference 'Micropost.count', 1 do
      count_sql 'Create a valid post' do
        post microposts_path, params: { micropost: { content: content,
                                                     image:   image } }
      end
      assert assigns(:micropost).image.attached?
    end

    count_sql 'Follow redirect after posting' do
      follow_redirect!
    end
    assert_match content, response.body
    # Delete a post.
    assert_select 'a', 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # Visit a different user (no delete links).
    get user_path(users(:archer))
    assert_select 'a', { text: 'delete', count: 0 }
  end
end
