## HomeBugh

[![Build Status](https://api.travis-ci.org/ck3g/homebugh.png)](https://travis-ci.org/github/ck3g/homebugh)
[![Code Climate](https://codeclimate.com/github/ck3g/homebugh/badges/gpa.svg)](https://codeclimate.com/github/ck3g/homebugh)
[![Test Coverage](https://codeclimate.com/github/ck3g/homebugh/badges/coverage.svg)](https://codeclimate.com/github/ck3g/homebugh)

The expense tracking app.

## About the project

HomeBugh app is a web application to track your home finance expenses.

There are a bunch of articles and books describing the benefit of tracking expenses.
So that's exactly what we do with my family. We track all our expenses.

There are plenty of ways to track your expenses, you can use an Excel spreadsheet, third-party applications.
I've decided to build a tool for myself.
That's how the project was born.

It has (almost) all required pieces of functionality I need.
And I work on some improvements from time to time.

## The project goal

Yet another goal of that project is to practice software development.
I've started it when I started to learn Ruby and Ruby on Rails.

It helped me to experiment with different code practices, implement the features I needed in the way I wanted and knew.

There are still some parts I'd like to implement.
I'm thinking to build a mobile application, that will require providing an API.

Another idea is to make the project available for everyone.
At the moment, I think I'm the only user of that application which is hosted on [HomeBugh.info](https://homebugh.info).

I understand some people don't want to share their personal finances with some service.
Based on that, I'd like to provide instructions for others to set up the project on their own hosting service.

I'm planning to add a demo user to the project, so everyone can take a look at the project without the need to register.

If the project gets more users, that should bring new ideas on improvements in different areas of the project.
So, if you want to practice web development that project can be a good place for you.

## The [Hacktoberfest](https://hacktoberfest.digitalocean.com) goal

To have fun. To help others to start contributing to the open-source.

That's not easy to start contributing to the open-source.
Especially at the beginning. There is a lot of stuff.
That's not easy to find an issue to work on or find something to improve by yourself.

I'll try to help here.
I'll create a bunch if easy to work on issues so everyone can pick up for Hacktoberfest.
Issues are relatively simple for a person with some basic knowledge of [Ruby on Rails](https://rubyonrails.org)
Issues have a small scope, so they can be easily implemented.
And more importantly, despite the narrow scope of issues, they will improve the project.

If you decide to participate, I'll try to help you as much as I can.

Welcome, and have fun!

<hr>

### Configure development environment

#### Prerequisites

Be sure there are required dependencies installed on your computer:

* Ruby version 2.7
* MySQL

#### Configuration steps

1. Fork and clone the repo `$ git clone git@github.com:ck3g/homebugh.git`
1. `$ cd homebugh`
1. Copy and update the database config according to your local MySQL configuration
    ```shell
    $ cp config/database.yml.example config/database.yml
    ```
1. Install all the required gems
    ```shell
    $ bundle
    ```
1. Migrate the database:
    ```shell
    $ bundle exec rails db:environment:set RAILS_ENV=development
    $ bundle exec rails db:create db:schema:load db:migrate db:test:prepare
    ```
1. Seed the database with required data
    ```shell
    $ bundle exec rails db:seed
    ```
1. Run the test suite to ensure everything is in working state
    ```shell
    bundle exec rspec spec/
    ```
1. Start the Rails server
    ```shell
    bundle exec rails s
    ```
1. Open http://localhost:3000 in your browser
1. Use `user@example.com` with the `password` to sign in.

#### How to deploy on Heroku

ℹ️ _That is an experimental approach, at the moment it requires some tweaks in the codebase to make it work. But we're working on improving that process._

1. You need to add to the `Gemfile` the gem `pg`. Example:
```ruby
  gem 'pg'
```

It's necessary because the Heroku natively uses PostgreSQL.

2. You need to change the `database.yml`. Example:
```ruby
development:
  adapter: postgresql
  encoding: unicode
  database: homebugh_development
```

3. First create an account on [Heroku](https://www.heroku.com/).
4. In the [dashboard](https://dashboard.heroku.com/apps) click in "New" and next "Create new app".
5. Fill in field "App name" with the name project. Example: `homebugh-development`.
6. Choose a region in this field. Available: United States or Europe and click in the button "Create app".
7. You'll redirected to dashboard again, now you need to make deploy, try to make deploy connected with your account in "GitHub".
8. In the field "Deployment method", choose the "GitHub", and downward ("App connected to GitHub") you need search your project and set they. For this, use the field "repo-name" to search your project.
9. After searched your project, click in button "Connect" and wait a couple of seconds.
10. Next, the field "Automatic deploys", you need to choose the branch, for example "master".
11. For the last, in the field "Manual deploy", click on the button "Deploy Branch" and wait a few minutes.
12. Enjoy! Your deploy already finished, you'll receive the message "Your app was successfully deployed." and the click in button "View", you'll redirected to your application with the name what you did set in the fifth pass (https://homebugh-development.herokuapp.com/).
13. If you've an another doubt, try to read the [documentation](https://devcenter.heroku.com/categories/reference) in Heroku.

### Contributing

Any contributions to the project are always welcome. Please check out the [Contributing guide](./CONTRIBUTING.md).

### License

HomeBugh app is released under the [MIT License](./LICENSE.md).
