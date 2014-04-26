class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.text :result
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
