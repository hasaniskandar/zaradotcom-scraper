class Job < ActiveRecord::Base
  after_update :done!, if: :result?, unless: :done?
  after_update :notify

  enum status: %i[pending in_progress done error]

protected

  def notify
    Resque.enqueue NotificationJob, id, ENV["EMAIL_SUBSCRIBERS"] if ENV["EMAIL_SUBSCRIBERS"].present? && status_changed? && (done? || error?)
  end
end
