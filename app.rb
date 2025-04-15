# app.rb
# The entry point that requires all the other files/modules and ties them together

$LOAD_PATH.unshift(File.join(__dir__, 'lib'))

# Require DB
require 'db/database'

# Require Portfolio pieces
require 'portfolio/portfolio_manager'
require 'portfolio/asset'
require 'portfolio/trade'
require 'portfolio/strategies/example_strategy'

# Require Chat
require 'chat/chat_room'
require 'chat/chat_server'

# Require server
require 'server/web_app'

module MyFinancialApp
  # This could include initialization tasks, background tasks, etc.
  # For demonstration, we’ll just put a simple module definition here.

  # Start up any needed background tasks, such as an algorithmic trading loop:
  Thread.new do
    loop do
      # Simple demonstration of running trades or strategies periodically
      # In a real system, you’d schedule or queue jobs more carefully.
      Portfolio::PortfolioManager.run_algorithmic_strategies
      sleep 10 # run every 10 seconds
    end
  end
end
