class Product < ApplicationRecord
  monetize :cost_cents
  belongs_to :seller, class_name: "User"
  validates :productName, uniqueness: true

end
