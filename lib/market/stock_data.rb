require 'net/http'
require 'json'

module Market
  class StockData
    # Cache stock prices with a timestamp: { symbol => { price: <Float>, fetched_at: <Time> } }
    @@cache = {}

    # API key from .env
    API_KEY = ""
    BASE_URL = "https://www.alphavantage.co/query"

    def self.fetch_price(symbol)
      # Return cached price if it's been fetched within the last 60 seconds.
      if @@cache[symbol] && Time.now - @@cache[symbol][:fetched_at] < 60
        return @@cache[symbol][:price]
      end

      # Build the query URL using the Global Quote endpoint.
      uri = URI(BASE_URL)
      params = { 
        "function" => "GLOBAL_QUOTE",
        "symbol"   => symbol,
        "apikey"   => API_KEY
      }
      uri.query = URI.encode_www_form(params)

      begin
        res = Net::HTTP.get(uri)
        data = JSON.parse(res)
        # Alpha Vantage returns the current price under "Global Quote" with the "05. price" key.
        if data["Global Quote"] && data["Global Quote"]["05. price"]
          price = data["Global Quote"]["05. price"].to_f
          @@cache[symbol] = { price: price, fetched_at: Time.now }
          price
        else
          # Fallback value in case the API doesn't return the expected data.
          100.0
        end
      rescue => e
        puts "Error fetching price for #{symbol}: #{e.message}"
        100.0
      end
    end
  end
end
