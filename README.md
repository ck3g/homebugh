## HomeBugh

[![Build Status](https://api.travis-ci.org/ck3g/homebugh.png)](https://travis-ci.org/profile/ck3g)
[![Code Climate](https://codeclimate.com/github/ck3g/homebugh/badges/gpa.svg)](https://codeclimate.com/github/ck3g/homebugh)
[![Test Coverage](https://codeclimate.com/github/ck3g/homebugh/badges/coverage.svg)](https://codeclimate.com/github/ck3g/homebugh)

The control system on household finances

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

### Contributing

Any contributions to the project are always welcome. Please check out the [Contributing guide](./CONTRIBUTING.md).

### License

HomeBugh app is released under the [MIT License](./LICENSE.md).
