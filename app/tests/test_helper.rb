require "json"
require "stringio"
require "minitest/autorun"
require "rack/mock"

require_relative "../src/app"
require_relative "../src/router"
require_relative "../src/products/repository"
require_relative "../src/products/controller"
require_relative "../src/users/repository"
require_relative "../src/users/controller"

class AppTest < Minitest::Test
  def setup
    products_repository = ProductsRepository.new
    users_repository = UsersRepository.new
    router = AppRouter.build(
      ProductsController.new(products_repository),
      UsersController.new(users_repository)
    )

    @app = App.new(router, users_repository)
    @client = Rack::MockRequest.new(@app)
    @stdout = $stdout
    $stdout = StringIO.new
  end

  def teardown
    $stdout = @stdout
  end

  private

  def post(path, params: {}, token: nil)
    @client.post(path, request_opts(params: params, token: token))
  end

  def get(path, token: nil)
    @client.get(path, request_opts(token: token))
  end

  def request_opts(params: nil, token: nil)
    opts = {}
    opts[:params] = params if params
    opts["HTTP_AUTHORIZATION"] = "Bearer #{token}" if token
    opts
  end

  def json(response)
    JSON.parse(response.body)
  end

  def create_user(username, password)
    post("/users", params: { "username" => username, "password" => password })
  end

  def login(username, password)
    post("/login", params: { "username" => username, "password" => password })
  end

  def session_token_for(username, password)
    create_user(username, password)
    json(login(username, password)).fetch("session_token")
  end

  def wait_for_products(token, expected_count: 1)
    deadline = Time.now + 6
    loop do
      products = json(get("/products", token: token))["products"]
      return products if products.size >= expected_count
      flunk "product was not created in time" if Time.now > deadline
      sleep 0.05
    end
  end
end
