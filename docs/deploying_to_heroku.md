# Deploying to Heroku


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
