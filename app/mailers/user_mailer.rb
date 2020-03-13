class UserMailer < ApplicationMailer

  def account_activation(email, username, type)
    mail to: email, subject: "Account activation: #{username} is #{type}"
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset"
  end
end
