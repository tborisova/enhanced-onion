class UserMailer < ApplicationMailer
  default from: 'Curry on Mars <product@contact.curryonmars.com>'

  def magic_link(user)
    @user = user
    @login_url = "curryonmars://login?token=#{user.login_token}"
    mail(to: @user.email, subject: 'Your Magic Login Link')
  end
end
