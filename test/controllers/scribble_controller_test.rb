require "test_helper"

class ScribbleControllerTest < ActionDispatch::IntegrationTest
  setup do
    @scribble = scribbles(:test)
  end

  test "should show scribble if found" do
    get scribble_url(name: @scribble.name)
    assert_response :success

    assert_select ".trix-content", text: /This is a test scribble for the minitest cases, now wrapped in Action Text!/
  end

  test "should redirect to new if scribble is not found" do
    get scribble_url(name: "does-not-exist")
    assert_redirected_to new_scribble_path(name: "does-not-exist")
    assert_equal "Item not found", flash[:alert]
  end

  test "should create scribble with valid parameters and redirect" do
    assert_difference("Scribble.count", 1) do
      post scribbles_url, params: {
        scribble: {
          body: "My Brand New Scribble",
          name: "Cool New Title!" # The concern will normalize this to "cool-new-title"
        }
      }
    end

    new_scribble = Scribble.last

    assert_redirected_to scribble_path(new_scribble)

    follow_redirect!
    assert_response :success

    assert_equal "cool-new-title", new_scribble.name
  end

  test "should not create scribble and render new with error status on failure" do
    assert_no_difference("Scribble.count") do
      # Passing invalid attributes (name is required in model)
      post scribbles_url, params: { scribble: { name: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "should not create scribble if body contains an attachment" do
    # A simulated action text payload containing an embedded file/image layout tag
    malicious_body = 'Here is a text <action-text-attachment sgid="123" content-type="image/png"></action-text-attachment>'

    assert_no_difference("Scribble.count") do
      post scribbles_url, params: {
        scribble: {
          name: "secureScribble",
          body: malicious_body
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
