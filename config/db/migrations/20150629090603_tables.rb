class Tables < ActiveRecord::Migration
  def change
    create_table(:rounds) do |t|
      t.string :title
      t.string :description
      t.date :deadline
      t.timestamps null: false
    end

    create_table(:questions) do |t|
      t.string :question
      t.belongs_to :round, index: true
      t.timestamps null: false
    end

    create_table(:votes) do |t|
      t.string  :user
      t.integer :vote
      t.belongs_to :question, index: true
      t.timestamps null: false
    end

    add_index :votes, [:user, :question_id], :unique => true
  end
end
