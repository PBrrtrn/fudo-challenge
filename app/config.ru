require "rack"
require "rack/reloader"
require_relative "src/app"
require_relative "src/router"
require_relative "src/products/repository"
require_relative "src/products/controller"
require_relative "src/users/repository"
require_relative "src/users/controller"
require_relative "src/middleware/compression"

use Rack::Reloader, 0
use Rack::CommonLogger

products_repository = ProductsRepository.new
products_controller = ProductsController.new(products_repository)

users_repository = UsersRepository.new
users_controller = UsersController.new(users_repository)

router = AppRouter.build(products_controller, users_controller)

use CompressionMiddleware
run App.new(router, users_repository)
