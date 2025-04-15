# lib/portfolio/portfolio_manager.rb

require 'securerandom'

module Portfolio
  class PortfolioManager
    def self.create_user(name:)
      user_id = SecureRandom.uuid
      DB::Database.users[user_id] = {
        name: name,
        portfolio: []
      }
      user_id
    end

    def self.place_trade(symbol:, quantity:, price:, trade_type:)
      # For simplicity, place all trades into a single “global portfolio”
      # or if you track by user, you’d attach it to that user’s portfolio.
      # This example uses a global portfolio with key :global.
      DB::Database.portfolios[:global] ||= []
      DB::Database.portfolios[:global] << Trade.new(
        symbol: symbol,
        quantity: quantity,
        price: price,
        trade_type: trade_type
      )
    end

    def self.calculate_performance
      # In a real system, you'd iterate over all trades or assets and figure out total performance.
      # We'll do a simplistic approach: sum up the “performance” of each asset
      # that was purchased and still held.
      portfolio = DB::Database.portfolios[:global] || []
      # Group by symbol for a naive approach
      holdings = {}

      portfolio.each do |trade|
        holdings[trade.symbol] ||= { quantity: 0, cost: 0.0 }
        if trade.trade_type == :buy
          holdings[trade.symbol][:quantity] += trade.quantity
          holdings[trade.symbol][:cost] += trade.price * trade.quantity
        else # :sell
          holdings[trade.symbol][:quantity] -= trade.quantity
          holdings[trade.symbol][:cost] -= trade.price * trade.quantity
        end
      end

      # For each symbol, evaluate current price vs cost
      performance_details = {}

      holdings.each do |symbol, data|
        next if data[:quantity] <= 0
        asset = Asset.new(
          symbol: symbol,
          quantity: data[:quantity],
          purchase_price: data[:cost] / data[:quantity]
        )
        performance_details[symbol] = {
          quantity: data[:quantity],
          avg_cost: data[:cost] / data[:quantity],
          current_value: asset.current_value,
          performance: asset.performance
        }
      end

      performance_details
    end

    def self.run_algorithmic_strategies
      # In a real system, we might have multiple strategies or a plugin system
      Strategies::ExampleStrategy.run
    end
  end
end
