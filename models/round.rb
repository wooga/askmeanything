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

  def hashed_mail(mail)
    sha256 = Digest::SHA256.new
    sha256.update(Sinatra::Application.settings.vote_secret)
    sha256.update(salt) if salt
    sha256.update(mail)
    sha256.hexdigest
  end
end
