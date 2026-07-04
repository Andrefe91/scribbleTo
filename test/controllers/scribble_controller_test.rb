require "test_helper"

class ScribbleControllerTest < ActionDispatch::IntegrationTest
  setup do
    @scribble = scribbles(:test)
    @secret_scribble = scribbles(:testProtected)

    @scribblePaperOne = scribbles(:paperTrailOne)
    @scribblePaperTwo = scribbles(:paperTrailTwo)

    #Modify the first scribble with update actions
    @scribble.update!(body: "This is the current live text.")
    @scribble.update!(body: "This is version two text.")
    @scribble.update!(body: "This is the ultimate third version text.")

    # Initialize the rich text bodies (this creates their "Current Version")
    @scribblePaperOne.update!(body: "Live Body One")
    @scribblePaperTwo.update!(body: "Private Live Body")

    # Perform an update to force PaperTrail to generate an older historical version
    @scribblePaperOne.update!(body: "Archived Version of One")
    @version_one = @scribblePaperOne.body.versions.last

    @scribblePaperTwo.update!(body: "Archived Secret Version")
    @version_two = @scribblePaperTwo.body.versions.last
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

  # Tests for PaperTrail versioning
  test "should get show view in standard live editable mode" do
    get scribble_url(@scribblePaperOne)
    assert_response :success

    assert_select "span.versionInfo", true
  end

  test "should load snapshot when passing valid version_id parameter" do
    get scribble_url(@scribblePaperOne, version_id: @version_one.id)
    assert_response :success

    assert_select "body", /Live Body One/
  end

  test "security scope: should block looking up version_id belonging to a different scribble" do
    # Try to sneak scribblePaperTwo's version ID into scribblePaperOne's URL parameter
    get scribble_url(@scribblePaperOne, version_id: @version_two.id)

    assert_redirected_to scribble_path(@scribblePaperOne)
    assert_equal "Version not found.", flash[:alert]
  end

  # Test for the download version options
  test "should download current scribble version as plain text" do
    get download_scribble_url(@scribble.name)

    assert_response :success

    # 1. Verify it sends the right header content types
    assert_equal "text/plain", response.media_type
    assert_equal "attachment; filename=\"#{@scribble.name}_current.txt\"; filename*=UTF-8''#{@scribble.name}_current.txt", response.headers["Content-Disposition"]

    # 2. Verify the raw file content matches our current plain text
    assert_equal "This is the ultimate third version text.", response.body.strip
  end

  test "should download historical scribble version when version_id is provided" do
    # Grab the very first version recorded in your version array
    first_version = @scribble.body.versions.second

    get download_scribble_url(@scribble.name, params: { version_id: first_version.id, normalizedVersion: 1 })

    assert_response :success
    assert_equal "text/plain", response.media_type
    assert_equal "attachment; filename=\"#{@scribble.name}_v#1.txt\"; filename*=UTF-8''#{@scribble.name}_v#1.txt", response.headers["Content-Disposition"]

    # Verify it accurately recovered the past version content string
    assert_equal "This is the current live text.", response.body.strip
  end

  test "should redirect and alert if historical version does not exist" do
    invalid_version_id = 999999

    get download_scribble_url(@scribble.name, params: { version_id: invalid_version_id })

    # Verify it doesn't stream a file, but instead sends them away
    assert_redirected_to scribble_path(@scribble)
    assert_equal "Version not found.", flash[:alert]
  end

end
