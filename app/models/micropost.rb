class Micropost < ApplicationRecord
  belongs_to       :user
  has_one_attached :picture
  # after_save       :resize_picture
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }

  def resize_picture
    picture.variant(resize_to_limit: [500, 500])
  end
end
