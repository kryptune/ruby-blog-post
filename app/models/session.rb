class Session < ApplicationRecord
  belongs_to :user
  validates :session_token, presence: true, uniqueness: true
  scope :active, -> { where("expires_at > ?", Time.current) }


end
