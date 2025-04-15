# lib/chat/chat_server.rb
require 'faye/websocket'
require 'json'
require 'thread'

module Chat
  class ChatServer
    KEEPALIVE_TIME = 15 # seconds
    @@connections = []  # Shared connection list

    def initialize(app)
      @app = app
    end

    def call(env)
      # (Optional) If you’re using Puma, you can force the hijack to be the underlying IO:
      if env['rack.hijack_io']
        env['rack.hijack'] = env['rack.hijack_io']
      end

      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, { ping: KEEPALIVE_TIME })

        user_id = nil
        username = nil

        ws.on :open do |_event|
          @@connections << ws
          puts "[WebSocket] Connection opened"
        end

        ws.on :message do |event|
          data = JSON.parse(event.data) rescue {}
          case data["type"]
          when "join"
            user_id = data["user_id"]
            username = data["username"]
            # Use fully-qualified class name:
            Chat::ChatRoom.join(user_id, username)
            broadcast({
              type: "system",
              message: "#{username} has joined the chat",
              active_users: Chat::ChatRoom.active_users
            })
          when "message"
            if user_id
              chat_entry = Chat::ChatRoom.post_message(user_id, data["message"])
              if chat_entry
                broadcast({
                  type: "message",
                  user_id: chat_entry[:user_id],
                  username: chat_entry[:username],
                  message: chat_entry[:message],
                  timestamp: chat_entry[:timestamp]
                })
              end
            end
          end
        end

        ws.on :close do |_event|
          puts "[WebSocket] Connection closed"
          Chat::ChatRoom.leave(user_id) if user_id
          @@connections.delete(ws)
          broadcast({
            type: "system",
            message: "#{username} left the chat",
            active_users: Chat::ChatRoom.active_users
          }) if username
          ws = nil
        end

        # Return asynchronous Rack response for WebSocket connections.
        ws.rack_response
      else
        @app.call(env)
      end
    end

    private

    def broadcast(message)
      @@connections.each do |conn|
        conn.send(message.to_json)
      end
    end
  end
end
