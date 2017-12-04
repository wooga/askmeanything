class Deanonymization < ActiveRecord::Migration
  def change
    add_column :questions, :questioner, :text
  end
end
