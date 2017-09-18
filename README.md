# README

This scheduling app is built with Ruby on Rails 5.1 using the API mode (which mostly removes unneccesary middleware used in MVC).

## Configuration and Running the app

I've chosen to use to docker and docker-compose for local development. Please follow the steps below to build and run the app

#### How to configure and run the app

1. Pull down this repo `git pull https://github.com/mlund01/scheduler.git`
2. Make sure you have the latest version of Docker ([mac](https://www.docker.com/docker-mac)/[windows](https://www.docker.com/docker-windows)) installed
3. Ensure that the Docker Engine is running after install
4. `cd` into the base project directory (where the Gemfile and README files sit)
5. Run `docker-compose build` -> This would be a good time to grab a drink... it'll take a few minutes the first time!
6. Run `docker-compose up` -> if you see "Listening on tcp://0.0.0.0:3000" in the logs for "app_1", it built correctly (ignore the postgres shutdown for now)
7. ctrl + c to kill the processes.
8. Run `docker-compose run app rails db:reset` -> this will build the development database
9. Run `docker-compose run app rails db:setup` -> this will load the schema, as well as seed the database (as defined in db/seed.rb)
10. Run `docker-compose up` and go to localhost:3000. If you see, "Yay, You're on Rails!", You did it!

#### A few notes on configuration setup

1. After going through these configuration steps the first time, you should only have to run `docker-compose up` from the project directory for future visits
2. ctrl + c usually works to kill all docker-compose processes, but it sometimes aborts instead (a known issue), so just use `docker-compose down` to stop the processes
3. Configuration for local dev is setup in docker-compose.yml for the main process and postgres
4. If you would like to query against the local database using the native terminal (psql for postgres in this case), it is easiest to run `docker-compose run app rails dbconsole` and then enter the db password set under the postgres service in the docker-compose.yml file

## How to use the API

1. This API uses basic authentication to provide for unique user experiences as required by the user stories. The usernames and credentials are stored in the .user_accounts.yml file, along with some details about each of the users (role, name, etc.)
2. Every endpoint requires that you include an 'Authorization' Header with a base64 encoding of "{username}:{password}" preceded by "Basic ". For example, `Authorization: Basic QUNmZWU5MmRmMmM2N2FjOWNNjU1NWM2OA==` (or just use something like Postman, which will encode the credentials and add the header for you).

## Testing the app

The Scheduler API is well tested with RSpec. The tests include unit tests for each model, and integration tests for each requirement from the user stories. All specs are under the specs directory

To run the tests, run rspec with docker-compose with RAILS_ENV set to 'test',

`docker-compose run -e "RAILS_ENV=test" app rspec`

To run all model unit tests, use file path with wild card,

`docker-compose run -e "RAILS_ENV=test" app rspec spec/models/*`

To run an individual unit, target the file and the test line number,

`docker-compose run -e "RAILS_ENV=test" app rspec spec/models/shift_spec:9`



