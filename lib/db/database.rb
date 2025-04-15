require 'sequel'
require 'fileutils'

module DB
  class Database
    FileUtils.mkdir_p('db')
    # Connect to a SQLite database file
    @db = Sequel.sqlite('db/portfolio.db')

    class << self
      attr_reader :db
    end

    def self.setup
      # Create the users table (for auth and to store strategy)
      unless @db.table_exists?(:users)
        @db.create_table :users do
          String :id, primary_key: true
          String :username, unique: true, null: false
          String :password, null: false
          String :strategy, default: 'none' # strategies: 'none', 'random', 'momentum', 'mean_reversion'
          DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
        end
      end

      # Create the trades table
      unless @db.table_exists?(:trades)
        @db.create_table :trades do
          primary_key :id
          String :user_id, null: false  # associate trade with a user
          String :symbol, null: false
          Integer :quantity, null: false
          Float :price, null: false
          String :trade_type, null: false  # 'buy' or 'sell'
          DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
        end
      end

      # Create the chat_messages table
      unless @db.table_exists?(:chat_messages)
        @db.create_table :chat_messages do
          primary_key :id
          String :user_id
          String :username
          String :message, text: true
          DateTime :timestamp, default: Sequel::CURRENT_TIMESTAMP
        end
      end
    end
  end
end

DB::Database.setup
