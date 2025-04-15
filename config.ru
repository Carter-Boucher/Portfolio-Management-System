
require_relative 'app'
use Rack::Session::Cookie, key: 'rack.session', secret: 'your_secret_key_here'
# Wrap the main WebApp with our ChatServer middleware so that chat requests are handled properly.
run Chat::ChatServer.new(MyFinancialApp::WebApp)

# config.ru

# require 'rack'
# require 'rack/session/cookie'
# require_relative 'lib/server/web_app'  # Make sure this path matches your structure

# use Rack::Session::Cookie,
#   key: 'rack.session',
#   path: '/',
#   secret: 'some_long_random_secret_value',  # Replace with a real secret in production
#   expire_after: 2592000                    # e.g., 30 days

# run MyFinancialApp::WebApp
