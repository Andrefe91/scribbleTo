require "test_helper"

class ScribbleVersionTest < ActiveSupport::TestCase
  setup do
    @scribble = Scribble.create!(name: "actiontextversion", body: "Initial Text")
  end

  test "editing the body creates a paper trail version" do
    assert_difference -> { @scribble.body.versions.count }, 1 do
      @scribble.body.update!(body: "First Edit")
    end
  end

  test "history stack caps out at exactly 15 versions" do
    # Perform 18 sequential edits to cross the 15-version limit
    18.times do |i|
      @scribble.body.update!(body: "Edit number #{i}")
    end

    # The database count must strictly clip and stay capped at 15
    assert_equal 15, @scribble.body.versions.count

    # Assert that the last (not current) version is indeed the number 16
    assert_includes @scribble.body.versions.last.reify.body.to_plain_text, "Edit number 16"
  end
end
