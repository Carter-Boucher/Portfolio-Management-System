# lib/chat/chat_room.rb

module Chat
    class ChatRoom
      def self.join(user_id, username)
        DB::Database.chat_users[user_id] = { name: username, active: true }
      end
  
      def self.leave(user_id)
        DB::Database.chat_users[user_id][:active] = false if DB::Database.chat_users[user_id]
      end
  
      def self.post_message(user_id, message)
        user = DB::Database.chat_users[user_id]
        if user && user[:active]
          chat_entry = {
            user_id: user_id,
            username: user[:name],
            message: message,
            timestamp: Time.now.to_s
          }
          DB::Database.chat_history << chat_entry
          chat_entry
        else
          nil
        end
      end
  
      def self.history
        DB::Database.chat_history
      end
  
      def self.active_users
        DB::Database.chat_users.select { |_, data| data[:active] }
      end
    end
  end
  