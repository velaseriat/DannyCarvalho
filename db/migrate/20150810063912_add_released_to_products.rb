class AddReleasedToProducts < ActiveRecord::Migration
  def change
    add_column :products, :release, :datetime
  end
end
