class NotificationJob
  @queue = :notifications

  def self.perform(job_id, emails)
    @job = Job.find job_id

    SystemMailer.job_notification(job_id, emails).deliver!
  end
end
