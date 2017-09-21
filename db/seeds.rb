# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create(
	:name => "Mary Lu",
	:role => :manager,
	:email => "mary@awesomegym.com",
	:password => "marylu123!"
	)

User.create(
	:name => "Bob Lob",
	:role => :manager,
	:email => "bob@awesomegym.com",
	:password => "boblob123!"
	)

User.create(
	:name => "Jim Miller",
	:role => :employee,
	:phone => "3444332212",
	:password => "jimmiller123!"
	)
User.create(
	:name => "Jamie Thomas",
	:role => :employee,
	:email => "jthomas@awesomegym.com",
	:password => "jamiethomas123!"
	)
User.create(
	:name => "Joice Ny",
	:role => :employee,
	:phone => "3444332214",
	:password => "joiceny123!"
	)
User.create(
	:name => "Larry Lewis",
	:role => :employee,
	:phone => "3444332215",
	:password => "larrylewis123!"
	)
User.create(
	:name => "Maddey Johnson",
	:role => :employee,
	:email => "mjohnson@awesomegym.com",
	:password => "maddeyjohnson123!"
	)


(1..50).each do |e|
	Shift.create(
		:manager_id => e % 2 + 1,
		:employee_id => e > 45 ? nil : e % 4 + 3,
		:start_time => Time.new + e.days,
		:end_time => Time.new + e.days + 5.hours
		)
	Shift.create(
		:manager_id => e % 2 + 1,
		:employee_id => e > 45 ? nil : e % 4 + 3,
		:start_time => Time.new - e.days,
		:end_time => Time.new - e.days + 5.hours
		)
end

Shift.create(
	:manager_id => 1,
	:employee_id => 3,
	:start_time => Time.utc(2017, 10, 30, 1, 0, 0),
	:end_time => Time.utc(2017, 10, 30, 5, 0, 0)
	)

Shift.create(
	:manager_id => 1,
	:employee_id => 3,
	:start_time => Time.utc(2017, 10, 29, 23, 0, 0),
	:end_time => Time.utc(2017, 10, 30, 3, 0, 0)
	)
