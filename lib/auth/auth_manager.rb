# lib/auth/auth_manager.rb
require 'securerandom'
require_relative '../db/database'

module Auth
  class AuthManager
    def self.register(username, password)
      users = DB::Database.db[:users]
      if users.where(username: username).count > 0
        raise "Username already exists"
      end
      user_id = SecureRandom.uuid
      users.insert(
        id: user_id,
        username: username,
        password: password,  # Note: for production use secure hashing!
        strategy: 'none',
        balance: 1000000
      )
      { "id" => user_id, "username" => username, "strategy" => "none", "balance" => 1000000 }
    end

    def self.authenticate(username, password)
      users = DB::Database.db[:users]
      user = users.where(username: username).first
      if user && user[:password] == password
        { "id" => user[:id], "username" => user[:username], "strategy" => user[:strategy], "balance" => user[:balance] }
      else
        nil
      end
    end
  end
end
