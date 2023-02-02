class Product < ApplicationRecord
  monetize :cost_cents
  belongs_to :seller, class_name: "User"
  validates :productName, presence: true
  validates :productName, uniqueness: true

end
