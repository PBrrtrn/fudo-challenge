require "rack"
require "rack/reloader"
require_relative "src/app"
require_relative "src/router"
require_relative "src/products/repository"
require_relative "src/products/controller"

use Rack::Reloader, 0
use Rack::CommonLogger

products_repository = ProductsRepository.new
products_controller = ProductsController.new(products_repository)

router = AppRouter.build(products_controller)

run App.new(router)
