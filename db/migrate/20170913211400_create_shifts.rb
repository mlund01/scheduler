class CreateShifts < ActiveRecord::Migration[5.1]
  def change
    create_table :shifts do |t|
      t.integer :manager_id
      t.integer :employee_id
      t.float :break
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end
end
