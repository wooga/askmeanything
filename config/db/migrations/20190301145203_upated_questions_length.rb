class UpatedQuestionsLength < ActiveRecord::Migration
  def change
    change_column :questions, :question, :string, :limit => 255
  end
end
