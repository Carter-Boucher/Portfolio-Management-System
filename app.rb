# app.rb
$LOAD_PATH.unshift(File.join(__dir__, 'lib'))

require 'db/database'
require 'auth/user'
require 'auth/auth_manager'
require 'portfolio/portfolio_manager'
require 'portfolio/asset'
require 'portfolio/trade'
require 'portfolio/strategies/random_strategy'
require 'portfolio/strategies/momentum_strategy'
require 'portfolio/strategies/mean_reversion_strategy'
require 'chat/chat_room'
require 'chat/chat_server'
require 'server/web_app'

module MyFinancialApp
  Thread.new do
    loop do
      Portfolio::PortfolioManager.run_algorithmic_strategies
      sleep 10
    end
  end
end
