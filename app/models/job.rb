class Job < ActiveRecord::Base
  enum status: %i[pending in_progress done error]
  serialize :result, JSON
end
