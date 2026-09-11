require "bcrypt"
require "securerandom"

class UsersRepository
  def initialize
    @next_id = 0
    @users = {}
    @sessions = {}
    @mutex = Mutex.new
  end

  def create(username, password)
    @mutex.synchronize do
      return nil if find_by_username_unsafe(username)

      user = {
        id: @next_id,
        username: username,
        password_digest: BCrypt::Password.create(password)
      }
      @users[@next_id] = user
      @next_id += 1
      public_user(user)
    end
  end

  def authenticate(username, password)
    @mutex.synchronize do
      user = find_by_username_unsafe(username)
      return nil unless user
      return nil unless BCrypt::Password.new(user[:password_digest]) == password

      token = SecureRandom.hex(32)
      @sessions[token] = user[:id]
      token
    end
  end

  def find_by_session_token(token)
    @mutex.synchronize do
      user_id = @sessions[token]
      return nil if user_id.nil?

      user = @users[user_id]
      return nil if user.nil?

      public_user(user)
    end
  end

  private

  def find_by_username_unsafe(username)
    @users.values.find { |user| user[:username] == username }
  end

  def public_user(user)
    { id: user[:id], username: user[:username] }
  end
end
