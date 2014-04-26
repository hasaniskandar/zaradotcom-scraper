class Job < ActiveRecord::Base
  after_update :done!, if: :result?, unless: :done?

  enum status: %i[pending in_progress done error]
end
