# Architecture

## Login and session management

### [Login a user (test/integration/users_login_test.rb)](tmp/appmap/minitest/Users_login_login_with_remembering.appmap.json)

Login is performed by SessionsController, without or without a remembering cookie.

### [Require a logged-in user (test/integration/following_test.rb)](tmp/appmap/minitest/Following_followers_page.appmap.json)

Logged-in user is enforced by a `before_action`. It's labeled `security.require_login`.

## Submit a post

### [Micropost integration test (test/integration/microposts_interface_test.rb)](tmp/appmap/minitest/Microposts_interface_micropost_interface.appmap.json).

This is a rather complex example, but it's comprehensive.
