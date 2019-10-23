class AddViewsToComments < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :comment_views, :integer
  end
end
