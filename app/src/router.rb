require "hanami/router"
require_relative "products/controller"
require_relative "users/controller"

module AppRouter
  def self.build(products_controller, users_controller)
    Hanami::Router.new do
      post "/users", to: users_controller.method(:create)
      post "/login", to: users_controller.method(:login)

      post "/products", to: products_controller.method(:create)
      get "/products", to: products_controller.method(:index)
      get "/products/:id", to: products_controller.method(:show)
    end
  end
end
