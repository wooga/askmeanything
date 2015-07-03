class Round < ActiveRecord::Base
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
  end

  def votable?
    deadline >= Time.now && active?
  end
end
