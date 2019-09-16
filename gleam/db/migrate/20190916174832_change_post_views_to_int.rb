class ChangePostViewsToInt < ActiveRecord::Migration[6.0]
  def change
	change_column :posts, :post_views, :integer, using: 'post_views::integer'
  end
end
