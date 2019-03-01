class UpatedQuestionsToBeText < ActiveRecord::Migration
  def change
    change_column :questions, :question, :text, :limit => 255
  end
end
