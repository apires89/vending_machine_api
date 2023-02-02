require 'rails_helper'
require "byebug"

RSpec.describe Api::V1::ProductsController, type: :controller do
  describe "GET #index" do
    let(:user) { FactoryBot.create(:seller) }
    before do
      sign_in user
    end
    let!(:products) { create_list(:product, 5) }

    it "returns all products" do
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to match_array(products.as_json)
    end
  end
  describe "POST #create" do
    let(:user) { FactoryBot.create(:seller) }
    before do
      sign_in user
    end

    context "with valid attributes" do
      let(:valid_attributes) { FactoryBot.attributes_for(:product) }

      it "creates a new product" do
        expect { post :create, params: { product: valid_attributes } }.to change(Product, :count).by(1)
      end

      it "returns the product" do
        post :create, params: { product: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to eq(Product.last.as_json)
      end
    end

    context "with invalid attributes" do
      let(:invalid_attributes) { FactoryBot.attributes_for(:product, productName: nil) }

      it "does not create a new product" do
        expect { post :create, params: { product: invalid_attributes } }.to_not change(Product, :count)
      end

      it "returns an error" do
        post :create, params: { product: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["data"]).to include("Productname can't be blank")      end
    end
  end


  describe "POST #buy" do
    let(:user) { FactoryBot.create(:seller) }
    before do
      sign_in user
    end
    let(:product) { FactoryBot.create(:product) }
    let(:buyer) { create(:buyer) }

    # it "logs out the user" do
    #   sign_out user
    #   expect(controller.user_signed_in?).to be_falsy
    # end
    before do
      sign_out user
    end

    context "when the buyer is not logged in" do

      before { post :buy, params: { id: product.id, product: { amount: 1 } } }

      it "returns not logged in" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["message"]).to eq("Not logged in")
      end
    end

    context "when the buyer is logged in" do
      before { sign_in buyer }

      context "when the deposit is enough to buy the product" do
        let(:deposit) { product.cost + Money.new(50) }

        before do
          buyer.update(deposit: deposit)
          post :buy, params: { id: product.id, product: { amount: 1 } }
        end

        it "returns purchase completed" do
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)["message"]).to eq("Purchase Completed!")
        end

        it "decreases the product amount" do
          expect(product.amountAvailable - 1).to eq(product.reload.amountAvailable)
        end

        it "decreases the buyer's deposit" do
          expect(buyer.reload.deposit).to eq(deposit - product.cost)
        end
      end

      context "when the deposit is not enough to buy the product" do
        let(:deposit) { product.cost - Money.new(50) }

        before do
          buyer.update(deposit: deposit)
          post :buy, params: { id: product.id, product: { amount: 1 } }
        end

        it "returns not enough money" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)["message"]).to eq("Not enough money to buy #{product.productName}")
        end
      end
    end
  end
end
