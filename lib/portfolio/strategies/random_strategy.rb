# lib/portfolio/strategies/random_strategy.rb
module Portfolio
    module Strategies
      class RandomStrategy
        def self.run_for(user_id)
          if rand > 0.5
            puts "[RandomStrategy] User #{user_id}: Buying 10 shares of DEMO"
            Portfolio::PortfolioManager.place_trade(user_id: user_id, symbol: 'DEMO', quantity: 10, price: 100, trade_type: 'buy')
          else
            puts "[RandomStrategy] User #{user_id}: Selling 5 shares of DEMO"
            Portfolio::PortfolioManager.place_trade(user_id: user_id, symbol: 'DEMO', quantity: 5, price: 100, trade_type: 'sell')
          end
        end
      end
    end
  end
  