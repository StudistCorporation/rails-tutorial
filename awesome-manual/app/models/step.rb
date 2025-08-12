class Step < ApplicationRecord
  belongs_to :manual
  
  has_one_attached :image
  
  validates :title, presence: true
  validates :position, presence: true, numericality: { greater_than: 0 }
end
