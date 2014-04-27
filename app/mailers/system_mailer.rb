class SystemMailer < ActionMailer::Base
  default from: "no-reply@zaradotcom-scraper.herokuapp.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.system_mailer.job.subject
  #
  def job_notification(id, emails)
    @job = Job.find id

    mail to: emails, subject: "[Job is #{@job.status.humanize}] zaradotcom-scraper job notification"
  end
end
