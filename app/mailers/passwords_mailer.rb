class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "Redefinir a sua palavra-passe", to: user.email_address
  end
end
