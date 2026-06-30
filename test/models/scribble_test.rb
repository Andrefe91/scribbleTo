require "test_helper"

class ScribbleTest < ActiveSupport::TestCase
  def build_scribble(name_value)
    Scribble.new(name: name_value, body: "This is the test body")
  end

  # --- Test 1: Normalization (.parameterize / .gsub logic) ---
  test "Should normalize with the class method" do
  assert_equal "my-cool-scribble", Scribble.normalizeName("  My Cool Scribble!!! ")
  end

  test "should normalize name by converting to lowercase and replacing spaces/special chars with hyphens" do
    scribble = build_scribble("My Awesome Scribble #1!")

    assert scribble.valid?
    assert_equal "my-awesome-scribble-1", scribble.name
  end

  # --- Test 2: Valid Character Whitelist ---
  test "should be valid with alphanumeric characters and hyphens" do
    valid_names = [ "valid-name", "name123", "123-456", "asd" ]

    valid_names.each do |valid_name|
      scribble = build_scribble(valid_name)
      assert scribble.valid?, "#{valid_name} should be valid"
    end
  end

  # --- Test 3: Length Constraints ---
  test "should be invalid if name is too short" do
    scribble = build_scribble("ab") # under 3 characters
    assert_not scribble.valid?
    assert_includes scribble.errors[:name], "is too short (minimum is 3 characters)"
  end

  test "should be invalid if name is too long" do
    scribble = build_scribble("a" * 51) # over 50 characters
    assert_not scribble.valid?
    assert_includes scribble.errors[:name], "is too long (maximum is 50 characters)"
  end

  # --- Test 4: Reserved Words Blacklist ---
  test "should be invalid if name is a reserved word" do
    reserved_words = %w[admin assets api about login settings]

    reserved_words.each do |word|
      scribble = build_scribble(word)
      assert_not scribble.valid?, "#{word} is a reserved word and should be invalid"
      assert_includes scribble.errors[:name], "'#{word}' is reserved and cannot be used"
    end
  end

  # --- Test 5: Uniqueness ---
  test "should enforce unique names case-insensitively" do
    existing_scribble = build_scribble("unique-name")
    existing_scribble.save!

    # Try to build a new record with the same name (different casing)
    duplicate_scribble = build_scribble("UNIQUE-name")

    assert_not duplicate_scribble.valid?
    assert_includes duplicate_scribble.errors[:name], "has already been taken"
  end

  # --- Test 6: Rails Routing Integration (to_param) ---
  test "to_param should return the name instead of the ID" do
    scribble = build_scribble("my-custom-route")
    assert_equal "my-custom-route", scribble.to_param
  end
end
