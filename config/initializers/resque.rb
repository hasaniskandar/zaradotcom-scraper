# Make sure resque does not get a stale db connection.
Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }
