# Preview all emails at http://localhost:3000/rails/mailers/system_mailer
class SystemMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/system_mailer/job
  def job
    SystemMailer.job
  end

end
