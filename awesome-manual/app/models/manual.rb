class Manual < ApplicationRecord
  has_many :steps, -> { order(:position) }, dependent: :destroy
  has_many :manual_tags, dependent: :destroy
  has_many :tags, through: :manual_tags
  
  has_one_attached :thumbnail
  
  accepts_nested_attributes_for :steps, allow_destroy: true
  
  validates :title, presence: true
end
