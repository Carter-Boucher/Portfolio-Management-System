# lib/portfolio/portfolio_manager.rb
module Portfolio
  class PortfolioManager
    def self.place_trade(user_id:, symbol:, quantity:, price:, trade_type:)
      trades = DB::Database.db[:trades]
      trades.insert(
        user_id: user_id,
        symbol: symbol,
        quantity: quantity,
        price: price,
        trade_type: trade_type
      )
    end

    def self.calculate_performance(user_id:)
      trades = DB::Database.db[:trades].where(user_id: user_id).all
      holdings = {}
      trades.each do |trade|
        symbol = trade[:symbol]
        holdings[symbol] ||= { quantity: 0, cost: 0.0 }
        if trade[:trade_type] == 'buy'
          holdings[symbol][:quantity] += trade[:quantity]
          holdings[symbol][:cost] += trade[:price] * trade[:quantity]
        else
          holdings[symbol][:quantity] -= trade[:quantity]
          holdings[symbol][:cost] -= trade[:price] * trade[:quantity]
        end
      end
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
      db = DB::Database.db
      users = db[:users].where{ strategy !~ 'none' }.all
      users.each do |user|
        case user[:strategy]
        when 'random'
          Portfolio::Strategies::RandomStrategy.run_for(user[:id])
        when 'momentum'
          Portfolio::Strategies::MomentumStrategy.run_for(user[:id])
        when 'mean_reversion'
          Portfolio::Strategies::MeanReversionStrategy.run_for(user[:id])
        end
      end
    end
  end
end
