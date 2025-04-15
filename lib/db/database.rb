# lib/db/database.rb
require 'sequel'
require 'fileutils'

module DB
  class Database
    FileUtils.mkdir_p('db')
    @db = Sequel.sqlite('db/portfolio.db')

    class << self
      attr_reader :db
    end

    def self.setup
      # Create the users table with a balance column.
      unless @db.table_exists?(:users)
        @db.create_table :users do
          String :id, primary_key: true
          String :username, unique: true, null: false
          String :password, null: false
          String :strategy, default: 'none'
          Float :balance, default: 1000000  # every account starts with 1,000,000
          DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
        end
      end

      # Create the trades table.
      unless @db.table_exists?(:trades)
        @db.create_table :trades do
          primary_key :id
          String :user_id, null: false  # associates trade with a user
          String :symbol, null: false
          Integer :quantity, null: false
          Float :price, null: false
          String :trade_type, null: false  # "buy" or "sell"
          DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
        end
      end

      # (Optional: Create a balance_history table if desired.)
      unless @db.table_exists?(:balance_history)
        @db.create_table :balance_history do
          primary_key :id
          String :user_id, null: false
          Float :balance, null: false
          DateTime :timestamp, default: Sequel::CURRENT_TIMESTAMP
        end
      end
    end
  end
end

DB::Database.setup
