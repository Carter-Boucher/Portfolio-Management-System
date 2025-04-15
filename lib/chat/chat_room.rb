module Chat
  class ChatRoom
    def self.join(user_id, username)
      # For persistence, you might not store chat users in DB—keep them in memory for active presence.
      @active_users ||= {}
      @active_users[user_id] = { name: username, active: true }
    end

    def self.leave(user_id)
      @active_users[user_id][:active] = false if @active_users && @active_users[user_id]
    end

    def self.active_users
      @active_users ||= {}
      @active_users.select { |_, data| data[:active] }
    end

    def self.post_message(user_id, message)
      # Retrieve user info from active users for display.
      return nil unless @active_users && @active_users[user_id]
      chat_entry = {
        user_id: user_id,
        username: @active_users[user_id][:name],
        message: message,
        timestamp: Time.now.to_s
      }
      # Insert into the chat_messages table.
      DB::Database.db[:chat_messages].insert(
        user_id: user_id,
        username: @active_users[user_id][:name],
        message: message,
        timestamp: Time.now
      )
      chat_entry
    end

    def self.history(limit = 50)
      # Retrieve the latest 50 messages
      DB::Database.db[:chat_messages].order(Sequel.desc(:timestamp)).limit(limit).all.reverse
    end
  end
end
