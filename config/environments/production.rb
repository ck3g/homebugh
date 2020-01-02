Homebugh::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  config.eager_load = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug
  config.log_formatter = ::Logger::Formatter.new
  config.log_level = :info

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server (Apache or nginx will already do this).
  config.serve_static_files = false

  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.0'

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  config.action_mailer.default_url_options = { host: "homebugh.info" }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    enable_starttls_auto: false,
    # port: 587,
    # address: "smtp.mailgun.org",
    # domain: 'mg.homebugh.info',
    # user_name: ENV['MAILGUN_USER'],
    # password: ENV['MAILGUN_PASSWORD'],
    # authentication: :plain
  }

  # Disable delivery errors, bad email addresses will be ignored
  config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Compress JavaScripts and CSS
  config.assets.js_compressor = :uglifier

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generated digest for assets URLs
  config.assets.digest = true

  # Notify exceptions
  # config.middleware.use ::ExceptionNotifier,
  #   email_prefix: "[HomeBugh Exceptions]: ",
  #   sender_address: "rakeroutes@mail.ru",
  #   exception_recipients: %w{kalastiuz@gmail.com}
end
