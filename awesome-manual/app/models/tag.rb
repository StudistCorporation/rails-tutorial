class Tag < ApplicationRecord
  has_many :manual_tags, dependent: :destroy
  has_many :manuals, through: :manual_tags
  
  validates :name, presence: true, uniqueness: true
end