require_relative "test_helper"

class UserCreationTest < AppTest
  def test_creates_a_user_with_username_and_password
    response = create_user("test-user", "secret")

    assert_equal 201, response.status
    body = json(response)
    assert_equal 0, body["id"]
    assert_equal "test-user", body["username"]
    refute body.key?("password")
    refute body.key?("password_digest")
  end

  def test_rejects_user_creation_without_credentials
    response = create_user("", "")

    assert_equal 400, response.status
    assert_equal "Validation error: User missing 'username' or 'password' field", json(response)["error"]
  end

  def test_rejects_duplicate_usernames
    create_user("test-user", "secret")
    response = create_user("test-user", "another")

    assert_equal 409, response.status
    assert_equal "Username already taken", json(response)["error"]
  end
end

class UserAuthenticationTest < AppTest
  def test_login_returns_a_session_token
    create_user("test-user", "secret")
    response = login("test-user", "secret")

    assert_equal 200, response.status
    token = json(response)["session_token"]
    refute_nil token
    refute_empty token
  end

  def test_login_rejects_invalid_credentials
    create_user("test-user", "secret")
    response = login("test-user", "wrong")

    assert_equal 401, response.status
    assert_equal "Invalid credentials", json(response)["error"]
  end

  def test_login_rejects_unknown_users
    response = login("nobody", "secret")

    assert_equal 401, response.status
    assert_equal "Invalid credentials", json(response)["error"]
  end

  def test_login_requires_username_and_password
    response = login("", "")

    assert_equal 400, response.status
    assert_equal "Validation error: User missing 'username' or 'password' field", json(response)["error"]
  end
end

class SessionValidationTest < AppTest
  def test_protected_endpoints_reject_missing_session_token
    response = get("/products")

    assert_equal 401, response.status
    assert_equal "Unauthorized", json(response)["error"]
  end

  def test_protected_endpoints_reject_invalid_session_token
    response = get("/products", token: "not-a-real-token")

    assert_equal 403, response.status
    assert_equal "Forbidden", json(response)["error"]
  end

  def test_valid_session_token_is_accepted
    token = session_token_for("test-user", "secret")
    response = get("/products", token: token)

    assert_equal 200, response.status
  end

  def test_public_endpoints_do_not_require_a_session
    users = create_user("test-user", "secret")
    login_response = login("test-user", "secret")

    assert_equal 201, users.status
    assert_equal 200, login_response.status
  end
end

class ProductEndpointsTest < AppTest
  def setup
    super
    @token = session_token_for("test-user", "secret")
  end

  def test_lists_products_when_authenticated
    response = get("/products", token: @token)

    assert_equal 200, response.status
    assert_equal [], json(response)["products"]
  end

  def test_rejects_product_creation_without_a_name
    response = post("/products", params: { "name" => "" }, token: @token)

    assert_equal 400, response.status
    assert_equal "Product missing 'name' field", json(response)["error"]
  end

  def test_creates_a_product_asynchronously_and_then_lists_it
    response = post("/products", params: { "name" => "pizza" }, token: @token)

    assert_equal 202, response.status
    assert_equal "Processing", json(response)["response"]
    assert_equal [], json(get("/products", token: @token))["products"]

    listed = wait_for_products(@token)
    assert_equal [{ "id" => 0, "name" => "pizza" }], listed
  end

  def test_shows_an_existing_product
    post("/products", params: { "name" => "pizza" }, token: @token)
    wait_for_products(@token)

    response = get("/products/0", token: @token)

    assert_equal 200, response.status
    assert_equal({ "id" => 0, "name" => "pizza" }, json(response)["product"])
  end

  def test_returns_not_found_for_unknown_product
    response = get("/products/99", token: @token)

    assert_equal 404, response.status
    assert_equal "Product not found", json(response)["error"]
  end

  def test_product_show_requires_a_valid_session
    missing = get("/products/0")
    invalid = get("/products/0", token: "nope")

    assert_equal 401, missing.status
    assert_equal 403, invalid.status
  end
end
