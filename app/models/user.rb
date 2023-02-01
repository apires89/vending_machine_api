class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
   devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self
  has_many :products, foreign_key: 'seller_id'
  monetize :deposit_cents
  validates :role, inclusion: { in: %w(seller buyer),
    message: "%{value} is not a valid role" }
  after_update :check_valid_deposit

  def jwt_payload
    super
  end


  def check_valid_deposit
    self.deposit.to_s.last(2) == "05" || self.deposit.to_s.last(2) == "00"
  end

  def change_user_to_seller
    self.update(role: "seller")
  end
end

