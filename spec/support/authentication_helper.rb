module AuthenticationHelper
  def sign_in(user, password: 'password', remember_me: '1')
    post login_path,
      params: {
        session: {
          email: user.email,
          password: password,
          remember_me: remember_me
        }
      }
  end
end