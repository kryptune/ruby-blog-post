class BlogPost < ApplicationRecord
  validates :title, :body, presence: true

  scope :draft, -> {where(published_at: nil)}
  scope :published, -> {where("published_at <= ?", Time.current )}
  scope :scheduled, -> {where("published_at > ?", Time.current )}

  def draft?
    published_at.nil?
  end
  def published?
    published_at.present? && published_at <= Time.current 
  end

  def scheduled?
    published_at.present? && published_at > Time.current 
  end

end

