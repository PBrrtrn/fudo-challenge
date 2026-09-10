require "hanami/router"
require_relative "products/controller"

module AppRouter
  def self.build(products_controller)
    Hanami::Router.new do
      post "/products", to: products_controller.method(:create)
      get "/products", to: products_controller.method(:index)
      get "/products/:id", to: products_controller.method(:show)
    end
  end
end