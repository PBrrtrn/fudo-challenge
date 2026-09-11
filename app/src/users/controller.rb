require "json"
require_relative "validator"
require_relative "repository"

class UsersController
  def initialize(repository)
    @repository = repository
  end

  def create(env)
    request = Rack::Request.new env

    unless UsersValidator.validate(request)
      return json_response(400, { error: "Validation error: User missing 'username' or 'password' field" })
    end

    user = @repository.create(request.params["username"], request.params["password"])
    return json_response(409, { error: "Username already taken" }) if user.nil?

    json_response(201, user)
  end

  def login(env)
    request = Rack::Request.new env

    unless UsersValidator.validate(request)
      return json_response(400, { error: "Validation error: User missing 'username' or 'password' field" })
    end

    token = @repository.authenticate(request.params["username"], request.params["password"])
    return json_response(401, { error: "Invalid credentials" }) if token.nil?

    json_response(200, { session_token: token })
  end

  private

  def json_response(status, payload)
    body = payload.to_json
    [status, { "content-type" => "application/json", "content-length" => body.bytesize.to_s }, [body]]
  end
end
