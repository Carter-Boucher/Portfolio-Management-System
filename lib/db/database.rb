# lib/db/database.rb

module DB
    class Database
      # Store data in hashes for demonstration
      @@users = {}
      @@portfolios = {}
      @@chat_history = []
      @@chat_users = {}
  
      # Provide getters/setters
      def self.users
        @@users
      end
  
      def self.portfolios
        @@portfolios
      end
  
      def self.chat_history
        @@chat_history
      end
  
      def self.chat_users
        @@chat_users
      end
    end
  end
  