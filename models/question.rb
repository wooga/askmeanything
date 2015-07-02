class Question < ActiveRecord::Base
  belongs_to :round
  has_many :votes

  def self.create_question_with_vote(params, user)
    Question.transaction do
      Question.create(params).vote(1, user)
    end
  end

  def self.join_vote_info(user, filter)
    votes_table_user = Vote.arel_table.alias("v1")
    questions_table = Question.arel_table

    query = all.select(questions_table[Arel.star])
      .select("rank() over (ORDER BY COALESCE(sum(v.vote), 0) desc) as rank")
      .select("COALESCE(sum(v.vote), 0) as score")
      .select("count(distinct v.id) as vote_count")
      .select("count(distinct v1.id) > 0 as voted")
      .select("count(NULLIF(v.vote, 1)) as down_votes")
      .select("count(NULLIF(v.vote, -1)) as up_votes")
      .select("max(v1.vote) as myvote")
      .joins("left join votes v on (v.question_id = questions.id)")
      .joins(questions_table.join(votes_table_user, Arel::Nodes::OuterJoin).on(
        votes_table_user[:question_id].eq(questions_table[:id]).and(
          votes_table_user[:user].eq(user))
        ).join_sources
      )
      .group(questions_table[:id])

    if filter == 'myvotes'
      query.having("count(distinct v1.id) > 0")
    elsif filter == 'notvoted'
      query.having("count(distinct v1.id) = 0")
    else
      query
    end
  end

  def vote(value, user)
    vote = Vote.where(:user => user, :question => self).first_or_create
    vote.vote = value
    vote.save
  end

  def voted?(user = nil)
    cached(:voted) do
      votes.any? {|vote| vote.user == user}
    end
  end

  def myvote(user = nil)
    cached(:myvote) do
      votes.find {|vote| vote.user == user}.try(:vote)
    end
  end

  def total_votes
    cached(:vote_count) do
      votes.count
    end
  end

  def score
    cached(:score) do
      votes.map(&:vote).sum
    end
  end

  def up_votes
    cached(:up_votes) do
      votes.map(&:vote).count(1)
    end
  end

  def down_votes
    cached(:down_votes) do
      votes.map(&:vote).count(-1)
    end
  end

  private
  def cached(value)
    if has_attribute?(value)
      read_attribute(value)
    elsif block_given?
      yield
    else
      nil
    end
  end
end
