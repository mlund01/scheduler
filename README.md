# README

This scheduling app is built with Ruby on Rails 5.1 using the API mode (which mostly removes unneccesary middleware used in MVC).

## Configuration and Running the app

I've chosen to use to docker and docker-compose for local development. Please follow the steps below to build and run the app

#### How to configure and run the app

1. Pull down this repo `git clone https://github.com/mlund01/scheduler.git`
2. Make sure you have the latest version of Docker ([mac](https://www.docker.com/docker-mac)/[windows](https://www.docker.com/docker-windows)) installed
3. Ensure that the Docker Engine is running after install
4. `cd` into the base project directory (where the Gemfile and README files sit)
5. Run `docker-compose build` -> This would be a good time to grab a drink... it'll take a few minutes the first time!
6. Run `docker-compose up` -> if you see "Listening on tcp://0.0.0.0:3000" in the logs for "app_1", it built correctly (ignore the postgres shutdown for now)
7. ctrl + c to kill the processes.
8. Run `docker-compose run app rails db:reset` -> this will build the development database
9. Run `docker-compose up` and go to localhost:3000. If you see, "Yay, You're on Rails!", You did it!

#### A few notes on configuration setup

1. After going through these configuration steps the first time, you should only have to run `docker-compose up` from the project directory for future visits
2. Whenever running `docker-compose build`, make sure the Gemfile.LOCK file is deleted. It will break the build if present.
3. ctrl + c usually works to kill all docker-compose processes, but it sometimes aborts instead (a known issue), so just use `docker-compose down` to stop the processes
4. Configuration for local dev is setup in docker-compose.yml for the main process and postgres
5. If you would like to query against the local database using the native terminal (psql for postgres in this case), it is easiest to run `docker-compose run app rails dbconsole` and then enter the db password set under the postgres service in the docker-compose.yml file

## Authentication

1. This API uses basic authentication to provide for unique user experiences as required by the user stories. For a list of users and their credentials, take a look at db/seeds.rb. Use the phone number or email as the username, password as password.
2. Every endpoint requires that you include an 'Authorization' Header with a base64 encoding of "{username}:{password}" preceded by "Basic ". For example, `Authorization: Basic QUNmZWU5MmRmMmM2N2FjOWNNjU1NWM2OA==` (or just use something like Postman, which will encode the credentials and add the header for you). Here is a full curl example,

```curl
curl http://localhost:3000/api/v1/shifts \
 -H "Authorization: Basic QUNmZWU5MmRmMmM2N2FjOWNNjU1NWM2OA=="

```

## Testing the app

The Scheduler API is well tested with RSpec. The tests include unit tests for each model and integration tests for each requirement from the user stories. All specs are under the specs directory

To run the tests, run rspec with docker-compose with RAILS_ENV set to 'test',

`docker-compose run -e "RAILS_ENV=test" app rspec`

To run all model unit tests, use file path with wild card,

`docker-compose run -e "RAILS_ENV=test" app rspec spec/models/*`

To run an individual unit, target the file and the test line number,

`docker-compose run -e "RAILS_ENV=test" app rspec spec/models/shift_spec:9`

## User stories -- steps to accomplish

#### Setup
Make sure you authenticate as one of the respective user types for each step.

1. As an employee, I want to know when I am working, by being able to see all of the shifts assigned to me.

##### Request

```shell
curl http://localhost:3000/api/v1/shifts?scope=assigned \
-H "Authorization: Basic QUNmZWU5MmRmMmM2N2FjOWNNjU1NWM2OA=="
```

##### Response

```js
[
    {
        "id": 4,
        "manager_id": 1,
        "employee_id": 3,
        "break": null,
        "start_time": "Mon, 25 Sep 2017 13:58:47 -0500",
        "end_time": "Mon, 25 Sep 2017 18:58:47 -0500",
        "created_at": "Thu, 21 Sep 2017 13:58:47 -0500",
        "updated_at": "Thu, 21 Sep 2017 13:58:47 -0500",
        "links": {
            "employee": "/api/v1/users/3",
            "manager": "/api/v1/users/1"
        }
    },
    {
        "id": 8,
        "manager_id": 1,
        "employee_id": 3,
        "break": null,
        "start_time": "Fri, 29 Sep 2017 13:58:47 -0500",
        "end_time": "Fri, 29 Sep 2017 18:58:47 -0500",
        "created_at": "Thu, 21 Sep 2017 13:58:47 -0500",
        "updated_at": "Thu, 21 Sep 2017 13:58:47 -0500",
        "links": {
            "employee": "/api/v1/users/3",
            "manager": "/api/v1/users/1"
        }
    }
]
```
This will return all shifts (past or present) that are assigned to the current employee, ordered descending by start_time

2. As an employee, I want to know who I am working with, by being able to see the employees that are working during the same time as me.

##### Request

```shell
curl http://localhost:3000/api/v1/users?shift_start=2014-03-05 00:00:00&shift_end=2014-03-05 05:00:00 \
-H "Authorization: Basic QUNmZWU5MmRmMmM2N2FjOWNNjU1NWM2OA=="
```

##### Response

```js
[
    {
        "id": 4,
        "name": "Jamie Thomas",
        "role": "employee",
        "email": "jthomas@awesomegym.com",
        "phone": null,
        "created_at": "Thu, 21 Sep 2017 13:58:47 -0500",
        "updated_at": "Thu, 21 Sep 2017 13:58:47 -0500"
    },
    {
        "id": 5,
        "name": "Joice Ny",
        "role": "employee",
        "email": null,
        "phone": "3444332214",
        "created_at": "Thu, 21 Sep 2017 13:58:47 -0500",
        "updated_at": "Thu, 21 Sep 2017 13:58:47 -0500"
    }
]
```

Pass in the start and end times of the employee shift, and it will only return users who have a shift that overlaps with that time period. Note that there is no validation that ensures the shift_start and shift_end match the employees shift. However, I believed this was the best and most standardized approach for accomplishing this feature (I thought about shift_id, but that didn't seem to make as much sense as a query param in the users resource)

3. As an employee, I want to be able to contact my managers, by seeing manager contact information for my shifts.

I decided it was most appropriate to keep the resources separate, and instead include links as REST specification suggests, so this user story takes two steps,

##### Request

```shell
curl http://localhost:3000/api/v1/shifts \
-H "Authorization: Basic QUNmZWU5MmRmMmM2N2FjOWNNjU1NWM2OA=="
```
Note there is no endpoint to access an individual shift, as no user story explicity specified a need for it, so we are using the list endpoint

##### Response
```js
[
    {
        "id": 4,
        "manager_id": 1,
        "employee_id": 3,
        "break": null,
        "start_time": "Mon, 25 Sep 2017 13:58:47 -0500",
        "end_time": "Mon, 25 Sep 2017 18:58:47 -0500",
        "created_at": "Thu, 21 Sep 2017 13:58:47 -0500",
        "updated_at": "Thu, 21 Sep 2017 13:58:47 -0500",
        "links": {
            "employee": "/api/v1/users/3",
            "manager": "/api/v1/users/1"
        }
    },
    {
        "id": 8,
        "manager_id": 1,
        "employee_id": 3,
        "break": null,
        "start_time": "Fri, 29 Sep 2017 13:58:47 -0500",
        "end_time": "Fri, 29 Sep 2017 18:58:47 -0500",
        "created_at": "Thu, 21 Sep 2017 13:58:47 -0500",
        "updated_at": "Thu, 21 Sep 2017 13:58:47 -0500",
        "links": {
            "employee": "/api/v1/users/3",
            "manager": "/api/v1/users/1"
        }
    }
]
```

From this point, to see manager contact details, you would make an api call to the link provided to the manager under "links", like so,

##### Request

```shell
curl http://localhost:3000/api/v1/users/1 \
-H "Authorization: Basic QUNmZWU5MmRmMmM2N2FjOWNNjU1NWM2OA=="
``` 

#### Response

```js
{
    "id": 1,
    "name": "Mary Lu",
    "role": "manager",
    "email": "mary@awesomegym.com",
    "phone": null,
    "created_at": "Thu, 21 Sep 2017 13:58:47 -0500",
    "updated_at": "Thu, 21 Sep 2017 13:58:47 -0500"
}
```

4. As an employee, I want to know how much I worked, by being able to get a summary of hours worked for each week.

Because hours are calculated from the shifts resource, I decided to include an additional endpoint under shifts to accomplish this feature,

##### Request

```shell
curl http://localhost:3000/api/v1/shifts/summary \
-H "Authorization: Basic QUNmZWU5MmRmMmM2N2FjOWNNjU1NWM2OA=="
```

##### Response

```js
[
    {
        "week_beginning": "Mon, 11 Sep 2017 05:00:00 -0000",
        "hours": 10
    },
    {
        "week_beginning": "Mon, 04 Sep 2017 05:00:00 -0000",
        "hours": 10
    },
    {
        "week_beginning": "Mon, 28 Aug 2017 05:00:00 -0000",
        "hours": 10
    },
    {
        "week_beginning": "Mon, 21 Aug 2017 05:00:00 -0000",
        "hours": 5
    },
    {
        "week_beginning": "Mon, 14 Aug 2017 05:00:00 -0000",
        "hours": 10
    },
    {
        "week_beginning": "Mon, 07 Aug 2017 05:00:00 -0000",
        "hours": 10
    }
]
```

This will deliver a list of hours broken down by week, in the past.

5. As a manager, I want to schedule my employees, by creating shifts for any employee,

Note: Make sure you authenticate as a manager user or you won't have access to this endpoint!

##### Request

```shell
curl -X POST http://localhost:3000/api/v1/shifts \
--data '{"employee_id": 3, "start_time": "Mon, 25 Sep 2017 13:58:47 -0500", "end_time": "Mon, 25 Sep 2017 18:58:47 -0500"}' \
-H "Authorization: Basic QUNmZWU5MmRmMmM2N2FjOWNNjU1NWM2OA=="
```

##### Response

```js
{
    "id": 4,
    "manager_id": 1,
    "employee_id": 3,
    "break": null,
    "start_time": "Mon, 25 Sep 2017 13:58:47 -0500",
    "end_time": "Mon, 25 Sep 2017 18:58:47 -0500",
    "created_at": "Thu, 21 Sep 2017 13:58:47 -0500",
    "updated_at": "Thu, 21 Sep 2017 13:58:47 -0500",
    "links": {
        "employee": "/api/v1/users/3",
        "manager": "/api/v1/users/1"
    }
}
```

6. As a manager, I want to see the schedule, by listing shifts within a specific time period,

Note: I built this feature to be inclusive of any shift that fell within the time range, meaning that only part of the shift has to fall within the range, not the entire shift from start to finish

##### Request

```shell
curl http://localhost:3000/api/v1/shifts?start=2017-09-21 13:58:47&end=2017-09-24 13:58:47 \
-H "Authorization: Basic QUNmZWU5MmRmMmM2N2FjOWNNjU1NWM2OA=="
```

##### Response

```js
[
    {
        "id": 1,
        "manager_id": 2,
        "employee_id": 4,
        "break": null,
        "start_time": "Fri, 22 Sep 2017 15:24:05 -0500",
        "end_time": "Fri, 22 Sep 2017 20:24:05 -0500",
        "created_at": "Thu, 21 Sep 2017 15:24:05 -0500",
        "updated_at": "Thu, 21 Sep 2017 15:24:05 -0500",
        "links": {
            "employee": "/api/v1/users/4",
            "manager": "/api/v1/users/2"
        }
    },
    {
        "id": 3,
        "manager_id": 1,
        "employee_id": 5,
        "break": null,
        "start_time": "Sat, 23 Sep 2017 15:24:05 -0500",
        "end_time": "Sat, 23 Sep 2017 20:24:05 -0500",
        "created_at": "Thu, 21 Sep 2017 15:24:05 -0500",
        "updated_at": "Thu, 21 Sep 2017 15:24:05 -0500",
        "links": {
            "employee": "/api/v1/users/5",
            "manager": "/api/v1/users/1"
        }
    }
]
```

7. As a manager, I want to be able to change a shift by update time details

##### Request

```shell
curl -X PUT http://localhost:3000/api/v1/shifts/3 \
--data '{"start_time": "Mon, 25 Sep 2017 13:58:47 -0500", "end_time": "Mon, 25 Sep 2017 18:58:47 -0500"}' \
-H "Authorization: Basic QUNmZWU5MmRmMmM2N2FjOWNNjU1NWM2OA=="
```

##### Response

```js
{
    "id": 3,
    "manager_id": 2,
    "employee_id": 4,
    "break": null,
    "start_time": "Mon, 25 Sep 2017 13:58:47 -0500",
    "end_time": "Mon, 25 Sep 2017 18:58:47 -0500",
    "created_at": "Thu, 21 Sep 2017 15:24:05 -0500",
    "updated_at": "Thu, 21 Sep 2017 18:24:05 -0500",
    "links": {
        "employee": "/api/v1/users/4",
        "manager": "/api/v1/users/2"
    }
}
```

8. As a manager, I want to be able to assign a shift, by changing the employee that will work the shift

##### Request

```shell
curl -X PUT http://localhost:3000/api/v1/shifts/3 \
--data '{"employee_id": 5}' \
-H "Authorization: Basic QUNmZWU5MmRmMmM2N2FjOWNNjU1NWM2OA=="
```

##### Response

```js
{
    "id": 3,
    "manager_id": 2,
    "employee_id": 5,
    "break": null,
    "start_time": "Mon, 25 Sep 2017 13:58:47 -0500",
    "end_time": "Mon, 25 Sep 2017 18:58:47 -0500",
    "created_at": "Thu, 21 Sep 2017 15:24:05 -0500",
    "updated_at": "Thu, 22 Sep 2017 18:24:05 -0500",
    "links": {
        "employee": "/api/v1/users/5",
        "manager": "/api/v1/users/2"
    }
}
```

9. As a manager, I want to contact an employee, by seeing employee details

As simple as getting the user with their id... also easy if you want to get the details of an employee from a shift, just use the link in the response object.


##### Request

```shell
curl http://localhost:3000/api/v1/users/5 \
-H "Authorization: Basic QUNmZWU5MmRmMmM2N2FjOWNNjU1NWM2OA=="
```

##### Response

```js
{
    "id": 5,
    "name": "Joice Ny",
    "role": "employee",
    "email": "jny@awesomegym.com",
    "phone": null,
    "created_at": "Thu, 21 Sep 2017 13:58:47 -0500",
    "updated_at": "Thu, 21 Sep 2017 13:58:47 -0500"
}
```

