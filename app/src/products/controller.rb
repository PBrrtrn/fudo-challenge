require_relative "validator"
require_relative "repository"

class ProductsController
  def initialize(repository)
    @repository = repository
  end

  def create(env)
    puts "Create product"
    request = Rack::Request.new env

    if !ProductsValidator.validate(env)
      [400, {}, ["Validation error: Product missing 'name' field"]]
    else
      Thread.new do
        sleep 5
        @repository.push(request.params["name"])
      end

      [202, {}, ["Processing"]]
    end
  end
  
  def index(env)
    puts "Fetching all products"
    [200, {}, []]
  end

  def show(env)
    puts "Show one product"
    [200, {}, []]
  end
end
