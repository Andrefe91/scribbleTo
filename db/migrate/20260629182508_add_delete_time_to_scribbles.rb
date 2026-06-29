class AddDeleteTimeToScribbles < ActiveRecord::Migration[8.1]
  def change
    add_column :scribbles, :deleteTime, :integer, default: 7
  end
end
