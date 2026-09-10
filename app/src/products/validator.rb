module ProductsValidator
  def self.validate(request)
    name = request.params["name"]
    !name.nil? && !name.strip.empty?
  end
end
