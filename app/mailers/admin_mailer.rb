class AdminMailer < ApplicationMailer
  default from: 'Curry on Mars <product@contact.curryonmars.com>'

  def magic_link(user)
    @user = user
    @login_url = "#{ENV.fetch('ADMIN_HOST', 'http://localhost:3000')}/admin/callback?token=#{user.login_token}"
    mail(to: @user.email, subject: 'Admin Login Link')
  end
end
