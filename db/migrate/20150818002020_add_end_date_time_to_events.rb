class AddEndDateTimeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :endDateTime, :datetime
  end
end
