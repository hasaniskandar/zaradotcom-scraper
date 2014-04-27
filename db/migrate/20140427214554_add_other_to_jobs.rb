class AddOtherToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :other, :text
  end
end
