module UsersValidator
  def self.validate(request)
    username = request.params["username"]
    password = request.params["password"]

    present?(username) && present?(password)
  end

  def self.present?(value)
    !value.nil? && !value.to_s.strip.empty?
  end
end
