FactoryGirl.define do
	factory :user do
		name "John Doe"
		password "johndoe123"
		email { "user_" + Random.rand(1000).to_s + "@gmail.com" }
	end
end