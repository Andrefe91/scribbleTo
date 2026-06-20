class CreateScribbles < ActiveRecord::Migration[8.1]
  def change
    create_table :scribbles do |t|
      t.string :name
      t.text :body
      t.boolean :locked

      t.timestamps
    end
  end
end
