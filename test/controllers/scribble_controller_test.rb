require "test_helper"

class ScribbleControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get scribble_show_url
    assert_response :success
  end

  test "should get new" do
    get scribble_new_url
    assert_response :success
  end

  test "should get create" do
    get scribble_create_url
    assert_response :success
  end
end
