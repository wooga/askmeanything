class DateToTime < ActiveRecord::Migration
  def change
    change_column :rounds, :deadline, :datetime
  end
end
