class RoundOwner < ActiveRecord::Migration
  def change
    add_column :rounds, :owner, :text
  end
end
