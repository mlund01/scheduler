FactoryGirl.define do
	factory :shift do
		start_time { Time.new + 1.hour }
		end_time { Time.new + 3.hours }
	end
end