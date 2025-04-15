module Portfolio
    module Strategies
      class MeanReversionStrategy
        def self.run_for(user_id)
          if rand > 0.7
            puts "[MeanReversionStrategy] User #{user_id}: Buying 5 shares of DEMO"
            Portfolio::PortfolioManager.place_trade(user_id: user_id, symbol: 'DEMO', quantity: 5, price: 100, trade_type: 'buy')
          else
            puts "[MeanReversionStrategy] User #{user_id}: Selling 5 shares of DEMO"
            Portfolio::PortfolioManager.place_trade(user_id: user_id, symbol: 'DEMO', quantity: 5, price: 100, trade_type: 'sell')
          end
        end
      end
    end
  end
  