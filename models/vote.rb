class Vote < ActiveRecord::Base
  validates :vote, inclusion: { in: [-1, 1]}
  belongs_to :question
end
