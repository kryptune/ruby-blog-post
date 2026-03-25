class User < ApplicationRecord
  has_secure_password
  before_create :generate_verification_token
  has_many :comments, dependent: :destroy

  # validates :password, presence: true, confirmation: true,
  #                      length: { minimum: 8,
  #                                message: "must be at least 8 characters long" }
  validate :password_complexity
  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true
  validates :terms, acceptance: true
  private

  def password_complexity
    return if password.blank?

    unless password.match?(/\d/) && password.match?(/[A-Z]/) && password.match?(/[a-z]/)
      errors.add :password, "must include at least one uppercase letter, one lowercase letter, and one digit"
    end
  end

  def generate_verification_token
    self.verification_token = SecureRandom.hex(20)
    self.email_verified = false
  end


end
