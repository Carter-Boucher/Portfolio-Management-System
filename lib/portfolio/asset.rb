# lib/portfolio/asset.rb

module Portfolio
    class Asset
      attr_accessor :symbol, :quantity, :purchase_price
  
      def initialize(symbol:, quantity:, purchase_price:)
        @symbol = symbol
        @quantity = quantity
        @purchase_price = purchase_price
      end
  
      # Calculate current value, for example by calling an external API.
      # We'll mock it here.
      def current_value
        current_price * @quantity
      end
  
      def current_price
        # In a real system, this might call some pricing API.
        # For demo, pretend all assets are $100
        100.0
      end
  
      def performance
        # Return a naive performance measure
        current_value - (@purchase_price * @quantity)
      end
    end
  end
  