require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  
  test "should redirect to scribble show when name param is present" do
    get root_url, params: { name: "test-scribble" }
    assert_redirected_to scribble_path(name: "test-scribble")
  end

  test "should load index successfully when name param is absent" do
    get root_url
    assert_response :success
  end
end
