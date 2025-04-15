
module Auth
    class User
      attr_accessor :id, :username, :password
  
      def initialize(username, password)
        @id = SecureRandom.uuid
        @username = username
        @password = password
      end
  
      def authenticate(attempt)
        password == attempt
      end
    end
  end
  