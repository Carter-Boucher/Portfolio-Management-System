# lib/portfolio/trade.rb

module Portfolio
    class Trade
      attr_accessor :symbol, :quantity, :price, :trade_type, :timestamp
  
      def initialize(symbol:, quantity:, price:, trade_type:)
        @symbol = symbol
        @quantity = quantity
        @price = price
        @trade_type = trade_type  # e.g. :buy or :sell
        @timestamp = Time.now
      end
    end
  end
  