class AnonymizedVoting < ActiveRecord::Migration
  def up
    add_column :rounds, :salt, :text
    add_column :votes, :hashed_mail, :text
    add_index :votes, [:hashed_mail, :question_id], :unique => true

    Round.all.each do |round|
      round.update(:salt => Round.generate_salt)
      round.questions.each do |question|
        question.votes.each do |vote|
          vote.update(:hashed_mail => round.hashed_mail(vote.user))
        end
      end
    end

    remove_index :votes, column: ["user", "question_id"]
    remove_column :votes, :user
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
