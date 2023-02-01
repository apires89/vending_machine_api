class Product < ApplicationRecord
  monetize :cost_cents
  belongs_to :seller, class_name: "User"
  validates :productName, uniqueness: true
  validate :check_if_user_is_seller


  def check_if_user_is_seller
    errors.add(:purchase, "user is a buyer, not a seller") if self.seller.role == "buyer"
  end
end
