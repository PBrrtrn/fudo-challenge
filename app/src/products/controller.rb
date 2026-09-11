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
      json_response 400, { error: "Product missing 'name' field" }
    else
      Thread.new do
        sleep 5
        @repository.push(request.params["name"])
        puts "Created product"
      end

      json_response 202, { response: "Processing" }
    end
  end
  
  def index(env)
    products = @repository.get_all
    json_response 200, { products: products }
  end

  def show(env)
    request = Rack::Request.new env

    product = @repository.get(request.params["id"].to_i)
    return json_response 404, { error: "Product not found" } if product.nil?

    return json_response 200, { product: product }
  end

  private

  def json_response(status, payload)
    body = payload.to_json
    [status, { "content-type" => "application/json", "content-length" => body.bytesize.to_s }, [body]]
  end

end
