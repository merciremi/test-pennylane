class CreateRecipes < ActiveRecord::Migration[7.0]
  def change
    create_table :recipes do |t|
      t.string :title
      t.string :author
      t.string :image
      t.integer :prep_time, default: 0
      t.integer :cook_time, default: 0
      t.float :rating, default: 0.00
      t.string :ingredients, array: true, default: []

      t.timestamps
    end
  end
end
