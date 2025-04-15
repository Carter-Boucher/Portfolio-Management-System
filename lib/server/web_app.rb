# lib/server/web_app.rb
require 'json'
require 'rack'

module MyFinancialApp
  class WebApp
    PUBLIC_DIR = File.expand_path('../../../public', __FILE__)
    
    def self.call(env)
      req = Rack::Request.new(env)

      # 1) Serve static files from the public folder.
      if req.get?
        public_path = File.join(PUBLIC_DIR, req.path_info)
        if File.file?(public_path)
          return [
            200,
            { 'Content-Type' => content_type(public_path) },
            [File.read(public_path)]
          ]
        end

        if req.path_info == '/'
          index_file = File.join(PUBLIC_DIR, 'index.html')
          return [
            200,
            { 'Content-Type' => 'text/html' },
            [File.read(index_file)]
          ]
        end
      end

      # 2) API endpoints
      if req.path == '/api/performance' && req.get?
        performance = Portfolio::PortfolioManager.calculate_performance
        return [
          200,
          { 'Content-Type' => 'application/json' },
          [performance.to_json]
        ]
      elsif req.path == '/api/trade' && req.post?
        data = JSON.parse(req.body.read) rescue {}
        Portfolio::PortfolioManager.place_trade(
          symbol: data["symbol"],
          quantity: data["quantity"].to_i,
          price: data["price"].to_f,
          trade_type: data["trade_type"]&.to_sym
        )
        return [
          200,
          { 'Content-Type' => 'application/json' },
          [{ status: "OK" }.to_json]
        ]
      end

      # 3) Fallback 404 response
      [
        404,
        { 'Content-Type' => 'application/json' },
        [{ error: "Not found" }.to_json]
      ]
    end

    def self.content_type(path)
      case File.extname(path)
      when '.html' then 'text/html'
      when '.css'  then 'text/css'
      when '.js'   then 'application/javascript'
      else 'text/plain'
      end
    end
  end
end
