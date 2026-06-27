# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Cleaning database 👀"
Scribble.destroy_all

puts "Seeding scribbles..."
Scribble.create!([
  {
    name: "test",
    body: "<h1>Welcome to the Test</h1><p>This is a test scribble for the test cases using <strong>Action Text</strong>.</p>",
    locked: false
  },
  {
    name: "test1",
    body: "This is a plain test scribble. Action Text converts this to HTML automatically.",
    locked: false
  },
  {
    name: "test2",
    body: "<p>This is the <em>second</em> test scribble.</p>",
    locked: false
  },
  {
    name: "gameofthrones",
    body: "<blockquote>When you play the game of thrones, you win or you die.</blockquote>",
    locked: true,
    password: "winteriscoming"
  }
])

puts "Done seeding! 🌱"
