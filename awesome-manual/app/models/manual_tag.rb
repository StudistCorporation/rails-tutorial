class ManualTag < ApplicationRecord
  belongs_to :manual
  belongs_to :tag
  
  validates :manual_id, uniqueness: { scope: :tag_id }
end