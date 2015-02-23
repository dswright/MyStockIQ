class Reply < ActiveRecord::Base

	belongs_to :user
	has_many :streams, as: :streamable, dependent: :destroy

	#FOR SOME REASON THE REPLY TEST DOESN"T RECOGNIZE USER ID AS A REPLY ATTRIBUTE
	#validates :user_id, presence: true, numericality: true
	validates :content, presence: true, length: { maximum: 140 }
	validates :popularity_score, presence: true, numericality: true



end
