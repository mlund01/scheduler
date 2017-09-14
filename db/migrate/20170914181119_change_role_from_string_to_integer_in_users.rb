class ChangeRoleFromStringToIntegerInUsers < ActiveRecord::Migration[5.1]
  def up
  	change_column :users, :role, "integer USING (CASE role WHEN 'employee' THEN '0'::integer ELSE '1'::integer END)", null: false
  end

  def down
  	change_column :users, :role, "varchar USING (CASE role WHEN '0' THEN 'employee'::varchar ELSE 'manager'::varchar END)"
  end
end
