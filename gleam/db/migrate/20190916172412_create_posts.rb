class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.string :content
      t.integer :post_views
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
