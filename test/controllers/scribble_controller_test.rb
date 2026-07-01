require "test_helper"

class ScribbleControllerTest < ActionDispatch::IntegrationTest
  setup do
    @scribble = scribbles(:test)
    @secret_scribble = scribbles(:testProtected)
  end

  test "should show scribble if found" do
    get scribble_url(name: @scribble.name)

    assert_response :success
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

  # Security checks

  test "should redirect to password gate when trying to view protected scribble" do
    get scribble_url(@secret_scribble)

    # Confirms it gets blocked and sent to the gate
    assert_redirected_to check_password_scribble_path(@secret_scribble.name)

    # Follow it through to ensure the password page actually renders
    follow_redirect!
    assert_response :success
    assert_select "h2", text: "This scribble is password protected"
  end

  test "should fail to unlock and show error banner with incorrect password" do
    # Post a wrong password to the handler
    post verify_password_scribble_path(@secret_scribble.name), params: { password: "wrong_password_here" }

    # Should kick them right back to the password entry gate
    assert_redirected_to check_password_scribble_path(@secret_scribble.name)

    # Check that the error message pops up on the screen
    follow_redirect!
    assert_not_nil flash[:alert]
    assert_select "p", text: "Incorrect Password..."

    # Verify they haven't bypassed security via the session
    assert_empty session[:unlocked_scribbles]
  end

  test "should successfully unlock scribble and store slug name in session with correct password" do
  post verify_password_scribble_path(@secret_scribble.name), params: { password: "password123" }

  assert_redirected_to scribble_path(@secret_scribble.name)
  follow_redirect!
  assert_response :success

  # CHANGE THIS: Look for something that only exists on your main show page
  # (For example, look for your trix-content class or scribble title)
  assert_select ".scribbleName"
  end

  # TEST FOR THE UPDATE CASE
  test "should update public scribble with valid parameters" do
    patch scribble_url(name: @scribble.name), params: {
      scribble: {
        body: "<div>This is newly updated body content!</div>"
      }
    }

    assert_redirected_to scribble_path(@scribble)
    assert_equal "Scribble was successfully updated!", flash[:notice]

    # Reload from DB and verify the Action Text content updated securely
    @scribble.reload
    assert_match "This is newly updated body content!", @scribble.body.to_s
  end

  test "should not update scribble with invalid parameters" do
    # Assuming 'name' has a validation (like presence: true) in your model
    patch scribble_url(name: @scribble.name), params: {
      scribble: { name: "" }
    }
    assert_response :unprocessable_entity
    # Verify that the name did not change in the database
    @scribble.reload
    assert_not_equal "", @scribble.name

    assert_select "form"
  end

  test "should redirect update to check_password if scribble is locked and not in session" do
    # Ensure the session does NOT have this protected scribble unlocked yet
    get root_url # simple request to initialize session
    session[:unlocked_scribbles] = []

    patch scribble_url(name: @secret_scribble.name), params: {
      scribble: { body: "Attempting a malicious edit!" }
    }

    assert_redirected_to check_password_scribble_path(@secret_scribble.name)
  end

  test "should redirect update to new when scribble name does not exist" do
    patch scribble_url(name: "completely-imaginary-scribble-name"), params: {
      scribble: { body: "Testing the rescue clause" }
    }

    # Triggers your custom set_scribble rescue rule
    assert_redirected_to new_scribble_path(name: "completely-imaginary-scribble-name")
    assert_equal "Item not found", flash[:alert]
  end
end
