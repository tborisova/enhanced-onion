class WebMailer < ApplicationMailer
  default from: 'Curry on Mars <product@contact.curryonmars.com>'

  def magic_link(user)
    @user = user
    @login_url = "#{ENV.fetch('WEB_HOST')}/callback?token=#{user.login_token}"
    mail(to: @user.email, subject: 'Sign in to Curry on Mars')
  end
end
