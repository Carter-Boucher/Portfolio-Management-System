# lib/auth/auth_manager.rb
require 'securerandom'
require_relative '../db/database'

module Auth
  class AuthManager
    def self.register(username, password)
      users = DB::Database.db[:users]
      # Check if username already exists
      if users.where(username: username).count > 0
        raise "Username already exists"
      end
      # Create a new user with strategy set to 'none'
      user_id = SecureRandom.uuid
      users.insert(
        id: user_id,
        username: username,
        password: password,  # (plain text for demo; use secure hashing in production)
        strategy: 'none'
      )
      # Return a hash with string keys
      { "id" => user_id, "username" => username, "strategy" => "none" }
    end

    def self.authenticate(username, password)
      users = DB::Database.db[:users]
      user = users.where(username: username).first
      if user && user[:password] == password
        # Return a hash with string keys
        { "id" => user[:id], "username" => user[:username], "strategy" => user[:strategy] }
      else
        nil
      end
    end
  end
end
