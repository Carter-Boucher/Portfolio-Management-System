# lib/portfolio/strategies/example_strategy.rb

module Portfolio
    module Strategies
      class ExampleStrategy
        def self.run
          # Example logic:
          # If random is > 0.5, place a buy, otherwise sell. 
          # This is obviously not a real strategy, but shows how you might plug in logic.
  
          if rand > 0.5
            puts "[Strategy] Buying 10 shares of DEMO"
            PortfolioManager.place_trade(symbol: "DEMO", quantity: 10, price: 100, trade_type: :buy)
          else
            puts "[Strategy] Selling 5 shares of DEMO"
            PortfolioManager.place_trade(symbol: "DEMO", quantity: 5, price: 100, trade_type: :sell)
          end
        end
      end
    end
  end
  