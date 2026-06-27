class RemoveBodyFromScribbles < ActiveRecord::Migration[8.1]
  def change
    remove_column :scribbles, :body, :text
  end
end
