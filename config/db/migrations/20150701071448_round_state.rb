class RoundState < ActiveRecord::Migration
  def change
    add_column :rounds, :state, :string, :default => 'active'
  end
end
