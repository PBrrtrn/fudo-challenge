require_relative "validator"
require_relative "repository"

class ProductsController
  def initialize(repository)
    @repository = repository
  end

  def create(env)
    puts "Creating product"
    request = Rack::Request.new env

    if !ProductsValidator.validate(request)
      [400, {}, ["Validation error: Product missing 'name' field"]]
    else
      Thread.new do
        sleep 5
        @repository.push(request.params["name"])
        puts "Created product"
      end

      [202, {}, ["Processing"]]
    end
  end
  
  def index(env)
    products = @repository.get_all
    [200, {"content-type" => "application/json"}, [products.to_json]]
  end

  def show(env)
    request = Rack::Request.new env

    product = @repository.get(request.params["id"].to_i)
    return [404, {"content-type" => "text/plain"}, ["Product not found"]] if product.nil?

    [200, {"content-type" => "application/json"}, [product.to_json]]
  end
end
