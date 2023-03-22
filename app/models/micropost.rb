class Micropost < ApplicationRecord
  belongs_to       :user
  has_one_attached :image
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image,   content_type: { in: %w[image/jpeg image/gif image/png],
                                      message: "must be a valid image format" },
                      size: { less_than: 5.megabytes,
                              message:   "should be less than 5MB" }

  # Get all the micropost on the db
  def Micropost.get_all
    query = <<-SQL
            SELECT * FROM microposts order by id DESC
            SQL
    ActiveRecord::Base.connection.execute(query)
  end

  # Returns a resized image for display.
  def display_image
    image.variant(resize_to_limit: [500, 500])
  end

  def generate_content
    Cicero.sentence
  end
end
