require 'rails_helper'
require 'devise'

RSpec.describe Api::V1::UsersController, type: :controller do
  describe "POST #deposit" do
    let(:user) { FactoryBot.create(:buyer) }
    before do
      sign_in user
    end

    context "with valid deposit amount" do
      it "adds deposit to user's account" do
        deposit_amount = 50
        post :deposit, params: { user: { deposit: deposit_amount } }

        expect(response).to have_http_status(:ok)
        expect(user.reload.deposit).to eq deposit_amount
      end
    end

    context "with invalid deposit amount" do
      it "returns unprocessable entity with error message" do
        deposit_amount = 35
        post :deposit, params: { user: { deposit: deposit_amount } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["message"]).to eq "Wrong input, only accepts 5, 10 ,20 ,50 or 100 cents"
      end
    end
  end
end
