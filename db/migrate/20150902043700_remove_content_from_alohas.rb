class RemoveContentFromAlohas < ActiveRecord::Migration
  def change
    remove_column :alohas, :content, :string
  end
end
