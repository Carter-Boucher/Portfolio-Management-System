# lib/server/web_app.rb
require 'json'
require 'rack'
require 'rack/utils'
#require auth
require_relative '../auth/auth_manager'

module MyFinancialApp
  class WebApp
    PUBLIC_DIR = File.expand_path('../../../public', __FILE__)

    def self.call(env)
      req = Rack::Request.new(env)

      # === Serve Static Files ===
      if req.get?
        public_path = File.join(PUBLIC_DIR, req.path_info)
        if File.file?(public_path)
          return [200, { 'Content-Type' => content_type(public_path) }, [File.read(public_path)]]
        end
        if req.path_info == '/'
          index_file = File.join(PUBLIC_DIR, 'index.html')
          return [200, { 'Content-Type' => 'text/html' }, [File.read(index_file)]]
        end
      end

      # === API Endpoints ===

      # Portfolio Performance for current user
      if req.path == '/api/performance' && req.get?
        if req.session["user"]
          performance = Portfolio::PortfolioManager.calculate_performance(user_id: req.session["user"]["id"])
          return [200, { 'Content-Type' => 'application/json' }, [performance.to_json]]
        else
          return [401, { 'Content-Type' => 'application/json' }, [{ error: "Not authenticated" }.to_json]]
        end
      end

      if req.path == '/api/quote' && req.get?
        symbol = req.params["symbol"]
        if symbol && !symbol.empty?
          price = Market::StockData.fetch_price(symbol)
          return [200, { 'Content-Type' => 'application/json' }, [{ price: price }.to_json]]
        else
          return [400, { 'Content-Type' => 'application/json' }, [{ error: "Missing symbol parameter" }.to_json]]
        end
      end      

      if req.path == '/api/trade' && req.post?
        if req.session["user"]
          data = JSON.parse(req.body.read) rescue {}
          user_id   = req.session["user"]["id"]
          symbol    = data["symbol"]
          quantity  = data["quantity"].to_i
          price     = data["price"].to_f
          trade_type = data["trade_type"]
      
          if trade_type == "buy"
            cost = price * quantity
            user = DB::Database.db[:users].where(id: user_id).first
            if user.nil? || user[:balance].to_f < cost
              return [400, { 'Content-Type' => 'application/json' }, [{ error: "Insufficient funds" }.to_json]]
            end
            # Deduct funds
            new_balance = user[:balance].to_f - cost
            DB::Database.db[:users].where(id: user_id).update(balance: new_balance)
            # (Optionally, record a snapshot in balance_history table here)
          elsif trade_type == "sell"
            holdings = Portfolio::PortfolioManager.calculate_holdings(user_id: user_id)
            if holdings[symbol].nil? || holdings[symbol] < quantity
              return [400, { 'Content-Type' => 'application/json' }, [{ error: "Insufficient shares to sell" }.to_json]]
            end
            sale_value = price * quantity
            user = DB::Database.db[:users].where(id: user_id).first
            new_balance = user[:balance].to_f + sale_value
            DB::Database.db[:users].where(id: user_id).update(balance: new_balance)
          end
      
          Portfolio::PortfolioManager.place_trade(
            user_id: user_id,
            symbol: symbol,
            quantity: quantity,
            price: price,
            trade_type: trade_type
          )
      
          # Update session with new balance.
          updated_user = DB::Database.db[:users].where(id: user_id).first
          req.session["user"]["balance"] = updated_user[:balance]
          return [200, { 'Content-Type' => 'application/json' },
                  [{ status: "OK", balance: updated_user[:balance] }.to_json]]
        else
          return [401, { 'Content-Type' => 'application/json' },
                  [{ error: "Not authenticated" }.to_json]]
        end
      end
      
      # API endpoint to get the current balance.
      if req.path == '/api/balance' && req.get?
        if req.session["user"]
          user = DB::Database.db[:users].where(id: req.session["user"]["id"]).first
          return [200, { 'Content-Type' => 'application/json' },
                  [{ balance: user[:balance] }.to_json]]
        else
          return [401, { 'Content-Type' => 'application/json' },
                  [{ error: "Not authenticated" }.to_json]]
        end
      end

      # Endpoint to get current user info
      if req.path == '/api/me' && req.get?
        if req.session["user"]
          return [200, { 'Content-Type' => 'application/json' }, [req.session["user"].to_json]]
        else
          return [401, { 'Content-Type' => 'application/json' }, [{ error: "Not authenticated" }.to_json]]
        end
      end

      # Strategy endpoint: GET returns current strategy; POST updates it.
      if req.path == '/api/strategy'
        if req.session["user"]
          if req.get?
            user = DB::Database.db[:users].where(id: req.session["user"]["id"]).first
            return [200, { 'Content-Type' => 'application/json' }, [{ strategy: user[:strategy] }.to_json]]
          elsif req.post?
            data = JSON.parse(req.body.read) rescue {}
            new_strategy = data["strategy"]
            DB::Database.db[:users].where(id: req.session["user"]["id"]).update(strategy: new_strategy)
            req.session["user"]["strategy"] = new_strategy
            return [200, { 'Content-Type' => 'application/json' }, [{ status: "OK", strategy: new_strategy }.to_json]]
          end
        else
          return [401, { 'Content-Type' => 'application/json' }, [{ error: "Not authenticated" }.to_json]]
        end
      end

      # === Authentication Routes ===
      if req.path == '/login' && req.get?
        return [
          200,
          { "Content-Type" => "text/html" },
          [login_html]
        ]
      end

      if req.path == '/login' && req.post?
        req_body = req.body.read
        params = Rack::Utils.parse_nested_query(req_body)
        user = ::Auth::AuthManager.authenticate(params["username"], params["password"])
        if user
          req.session["user"] = user
          return [302, { 'Location' => '/' }, []]
        else
          return [401, { 'Content-Type' => 'text/html' }, ["Login failed. <a href='/login'>Try again</a>"]]
        end
      end

      if req.path == '/register' && req.get?
        return [200, { 'Content-Type' => 'text/html' }, [register_html]]
      end

      if req.path == '/register' && req.post?
        req_body = req.body.read
        params = Rack::Utils.parse_nested_query(req_body)
        begin
          user = ::Auth::AuthManager.register(params["username"], params["password"])
          req.session["user"] = user
          return [302, { 'Location' => '/' }, []]
        rescue => e
          return [400, { 'Content-Type' => 'text/html' }, [e.message + " <a href='/register'>Try again</a>"]]
        end
      end

      if req.path == '/logout'
        req.session.clear
        return [302, { 'Location' => '/login' }, []]
      end

      [404, { 'Content-Type' => 'application/json' }, [{ error: "Not found" }.to_json]]
    end

    def self.content_type(path)
      case File.extname(path)
      when '.html' then 'text/html'
      when '.css'  then 'text/css'
      when '.js'   then 'application/javascript'
      else 'text/plain'
      end
    end

    # login page HTML ...
    def self.login_html
      <<-HTML
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Login</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container mt-5">
  <h1>Login</h1>
  <form method="POST" action="/login">
    <div class="mb-3">
      <label for="username" class="form-label">Username</label>
      <input type="text" class="form-control" name="username" id="username" required>
    </div>
    <div class="mb-3">
      <label for="password" class="form-label">Password</label>
      <input type="password" class="form-control" name="password" id="password" required>
    </div>
    <button type="submit" class="btn btn-primary">Login</button>
  </form>
  <p class="mt-3">Don't have an account? <a href="/register">Register here</a></p>
</body>
</html>
      HTML
    end

    def self.register_html
      <<-HTML
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Register</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container mt-5">
  <h1>Register</h1>
  <form method="POST" action="/register">
    <div class="mb-3">
      <label for="username" class="form-label">Username</label>
      <input type="text" class="form-control" name="username" id="username" required>
    </div>
    <div class="mb-3">
      <label for="password" class="form-label">Password</label>
      <input type="password" class="form-control" name="password" id="password" required>
    </div>
    <button type="submit" class="btn btn-primary">Register</button>
  </form>
  <p class="mt-3">Already have an account? <a href="/login">Login here</a></p>
</body>
</html>
      HTML
    end
  end
end
