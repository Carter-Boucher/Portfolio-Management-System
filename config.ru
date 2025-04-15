# config.ru

require_relative 'app'
use Rack::Session::Cookie, key: 'rack.session', secret: 'your_secret_key_here'
# Wrap the main WebApp with our ChatServer middleware
run Chat::ChatServer.new(MyFinancialApp::WebApp)
