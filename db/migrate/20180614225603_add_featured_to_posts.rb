class AddFeaturedToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :comfy_blog_posts, :featured, :boolean
  end
end
