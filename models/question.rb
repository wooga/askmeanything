require 'statistics2'

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
    up_votes_query_string = "count(NULLIF(v.vote, -1))"
    down_votes_query_string = "count(NULLIF(v.vote, 1))"
    # wilson score explanation: http://www.evanmiller.org/how-not-to-sort-by-average-rating.html
    wilson_query_string =
      "CASE WHEN #{up_votes_query_string} + #{down_votes_query_string} > 0" +
      " THEN ROUND(((#{up_votes_query_string} + 1.9208) /" +
      " (#{up_votes_query_string} + #{down_votes_query_string}) - 1.96 *" +
      " SQRT((#{up_votes_query_string} * #{down_votes_query_string}) /" +
      " (#{up_votes_query_string} + #{down_votes_query_string}) + 0.9604) /" +
      " (#{up_votes_query_string} + #{down_votes_query_string})) /" +
      " (1 + 3.8416 / (#{up_votes_query_string} +" +
      " #{down_votes_query_string})), 2) ELSE 0 END"
    query = all.select("questions.*")
      .select("rank() over (ORDER BY #{wilson_query_string} DESC) as rank")
      .select("#{wilson_query_string} as score")
      .select("count(distinct v.id) as vote_count")
      .select("count(distinct v1.id) > 0 as voted")
      .select("#{down_votes_query_string} as down_votes")
      .select("#{up_votes_query_string} as up_votes")
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
      n = total_votes
      pos = up_votes
      if n == 0
        return 0
      end
      z = Statistics2.pnormaldist(1-(1-0.95)/2)
      phat = 1.0*pos/n
      ((phat + z*z/(2*n) - z * Math.sqrt((phat*(1-phat)+z*z/(4*n))/n))/(1+z*z/n)).round(2)
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
