class AddPasswordToScribbles < ActiveRecord::Migration[8.1]
  def change
    add_column :scribbles, :password_digest, :string
  end
end
