class Comment < ActiveRecord::Base
  belongs_to :stream
  default_scope -> { order(created_at: :desc) }
  #content exists and has a max length of 140 characters
  validates :content, presence: true, length: {maximum: 140}
end
