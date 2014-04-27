require 'test_helper'

class SystemMailerTest < ActionMailer::TestCase
  test "job" do
    mail = SystemMailer.job
    assert_equal "Job", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
