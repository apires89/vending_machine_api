role = ["seller", "buyer"]
emails = []
products = []
while emails.size < 20
  email = Faker::Internet.email
  emails << email unless emails.include?(email)
end

while products.size < 20
  product = Faker::Food.dish
  products << product unless products.include?(product)
end

FactoryBot.define do
  factory :seller, class: "User" do
    email { emails.pop }
    password { "123456" }
    role { "seller" }
    deposit { rand(1...5) }
  end
  factory :buyer, class: "User" do
    email { emails.pop }
    password { "123456" }
    role { "buyer" }
    deposit { rand(1...5) }
  end

  factory :product do
    amountAvailable { rand(2..5) }
    cost { rand(1...2) }
    productName { products.pop }
    seller { User.find_by(role: "seller")}
  end
end
