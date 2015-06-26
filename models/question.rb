class Question < ActiveRecord::Base
  belongs_to :round
  has_many :votes

  CurrentUserJoinCondition = <<-SQL
    LEFT JOIN votes v1 ON (
      v1.question_id = questions.id AND v1.hashed_mail = %{hashed_mail}
    )
  SQL

  def self.create_question_with_vote(params, mail)
    Question.transaction do
      Question.create(params).vote(1, mail)
    end
  end

  def self.create_question(params)
    Question.transaction { Question.create(params) }
  end

  def self.join_vote_info(round, mail, filter)
    query = all.select("questions.*")
      .select("rank() over (ORDER BY COALESCE(sum(v.vote), 0) desc) as rank")
      .select("COALESCE(sum(v.vote), 0) as score")
      .select("count(distinct v.id) as vote_count")
      .select("count(distinct v1.id) > 0 as voted")
      .select("count(NULLIF(v.vote, 1)) as down_votes")
      .select("count(NULLIF(v.vote, -1)) as up_votes")
      .select("max(v1.vote) as myvote")
      .joins("left join votes v on (v.question_id = questions.id)")
      .joins(CurrentUserJoinCondition % {
        :hashed_mail => ActiveRecord::Base.sanitize(round.hashed_mail(mail))
      })
      .where(:round => round)
      .group("questions.id")

    if filter == 'myvotes'
      query.having("count(distinct v1.id) > 0")
    elsif filter == 'notvoted'
      query.having("count(distinct v1.id) = 0")
    else
      query
    end
  end

  def vote(value, mail)
    vote = Vote.where(:hashed_mail => round.hashed_mail(mail), :question => self).first_or_create
    vote.vote = value
    vote.save
  end

  def voted?(mail = nil)
    aggregated_value(:voted) do
      votes.any? {|vote| vote.hashed_mail == round.hashed_mail(mail)}
    end
  end

  def myvote(mail = nil)
    aggregated_value(:myvote) do
      votes.find {|vote| vote.hashed_mail == round.hashed_mail(mail)}.try(:vote)
    end
  end

  def total_votes
    aggregated_value(:vote_count) do
      votes.count
    end
  end

  def score
    aggregated_value(:score) do
      votes.map(&:vote).sum
    end
  end

  def up_votes
    aggregated_value(:up_votes) do
      votes.map(&:vote).count(1)
    end
  end

  def down_votes
    aggregated_value(:down_votes) do
      votes.map(&:vote).count(-1)
    end
  end

  private
  def aggregated_value(value)
    if has_attribute?(value)
      read_attribute(value)
    elsif block_given?
      yield
    else
      nil
    end
  end
end
