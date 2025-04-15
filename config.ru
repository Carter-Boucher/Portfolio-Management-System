require_relative 'app'

# Wrap the main WebApp with the ChatServer middleware.
run Chat::ChatServer.new(MyFinancialApp::WebApp)
