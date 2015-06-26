class Round < ActiveRecord::Base
  before_create :add_default_salt_value

  validates :title, presence: true
  validates :deadline, presence: true

  has_many :questions

  default_scope do
    order('deadline desc')
  end

  state_machine :state, :initial => :active do
    event :deactivate do
      transition :active => :inactive
    end
    event :activate do
      transition :inactive => :active
    end
    event :finalize do
      transition :inactive => :finalized
    end
    before_transition any => :finalized do |round, transition|
      round.salt = nil
    end
  end

  def self.generate_salt
    SecureRandom.hex
  end

  def votable?
    deadline >= Time.now && active?
  end

  def add_default_salt_value
    self.salt ||= Round.generate_salt
  end

  def votes_statistics
    uv, dv = questions.map { |q| [q.up_votes, q.down_votes] }.
      inject([0,0]) { |a, b| [b[0]+a[0], b[1]+a[1]] }
    { "total_votes" => uv+dv, "up_votes" => uv, "down_votes" => dv }.tap do |h|
      h["voters"] = questions.
        map { |a| a.votes.map { |b| b.hashed_mail  } }.flatten.uniq.count
    end
  end

  def hashed_mail(mail)
    sha256 = Digest::SHA256.new
    sha256.update(Sinatra::Application.settings.vote_secret)
    sha256.update(salt) if salt
    sha256.update(mail)
    sha256.hexdigest
  end
end
