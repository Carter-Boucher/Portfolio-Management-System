# lib/portfolio/asset.rb
require_relative '../market/stock_data'

module Portfolio
  class Asset
    attr_accessor :symbol, :quantity, :purchase_price

    def initialize(symbol:, quantity:, purchase_price:)
      @symbol = symbol
      @quantity = quantity
      @purchase_price = purchase_price
    end

    # Use the Market::StockData module to get the current price.
    def current_price
      Market::StockData.fetch_price(@symbol)
    end

    def current_value
      current_price * @quantity
    end

    def performance
      current_value - (@purchase_price * @quantity)
    end
  end
end
