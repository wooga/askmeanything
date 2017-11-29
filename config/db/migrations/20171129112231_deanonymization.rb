class Deanonymization < ActiveRecord::Migration
  def change
    add_column :questions, :mail, :text
  end
end
