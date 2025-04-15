# lib/portfolio/strategies/momentum_strategy.rb
module Portfolio
    module Strategies
      class MomentumStrategy
        def self.run_for(user_id)
          if rand < 0.3
            puts "[MomentumStrategy] User #{user_id}: Buying 15 shares of DEMO"
            Portfolio::PortfolioManager.place_trade(user_id: user_id, symbol: 'DEMO', quantity: 15, price: 100, trade_type: 'buy')
          else
            puts "[MomentumStrategy] User #{user_id}: Selling 10 shares of DEMO"
            Portfolio::PortfolioManager.place_trade(user_id: user_id, symbol: 'DEMO', quantity: 10, price: 100, trade_type: 'sell')
          end
        end
      end
    end
  end
  