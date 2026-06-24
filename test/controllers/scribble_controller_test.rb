require "test_helper"

class ScribbleControllerTest < ActionDispatch::IntegrationTest
  setup do
    @scribble = scribbles(:test)
  end

  test "should show scribble if found" do
    get scribble_url(name: @scribble.name)
    assert_response :success
    # puts "Response body: #{response.body}"
    assert_match @scribble.body, response.body
  end

  test "should redirect to new if scribble is not found" do
    get scribble_url(name: "does-not-exist")
    assert_redirected_to new_scribble_path(name: "does-not-exist")
    assert_equal "Item not found", flash[:alert]
  end

  test "should create scribble with valid params" do
    assert_difference("Scribble.count") do
      post scribbles_url, params: { name: "unique-name", body: "text", password: "123" }
    end

    assert_redirected_to scribble_path(Scribble.last)
    assert_equal "Scribble was successfully created!", flash[:notice]
  end

  test "should not create scribble and render new with error status on failure" do
    assert_no_difference("Scribble.count") do
      # Passing invalid attributes (assuming name is required in model)
      post scribbles_url, params: { scribble: { name: "" } }
    end

    assert_response :unprocessable_entity
  end
end
