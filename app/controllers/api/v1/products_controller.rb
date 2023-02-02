class Api::V1::ProductsController < Api::V1::BaseController
  before_action :set_product, only: [ :show, :update, :destroy ]
  before_action :check_login, except: [:index,:show]
  def index
    @products = Product.all
    render json: @products, status: :ok
  end

  def show
    render json: @product, status: :ok
  end

  def create
    @product = current_user.products.new(product_params)
    if @product.save
      render json: @product, status: :created
    else
      render json: { data: @product.errors.full_messages, status: "failed" }, status: :unprocessable_entity
    end
  end

  def update
    if @product.seller == current_user && @product.update(product_params)
      render json: @product, status: :ok
    else
      render json: { data: @product.errors.full_messages, status: "failed" }, status: :unprocessable_entity
    end
  end

  def destroy
    if @product.seller == current_user && @product.destroy
      render json: { data: 'product deleted successfully', status: 'sucess' }, status: :ok
    else
      render json: { data: 'Something went wrong', status: 'failed' }
    end
  end

  def buy
    #accepts productId and amount
    check_input_for_purchase
    #user with buyuer role can buy a product
    if current_user.role == "buyer"
      @deposit = current_user.deposit
    else
      render json: { message: "Not a customer, or something went wrong.", status: "failed" }, status: :unprocessable_entity
      return
    end
    #with deposited money
    if @product.cost > @deposit
      render json: { message: "Not enough money to buy #{@product.productName}", status: "failed" }, status: :unprocessable_entity
    else
      #api should return total spent, product purchased and change
      calculate_output
    end
  end

  private

  def product_params
    params.require(:product).permit(:productName, :cost, :amountAvailable, :seller_id)
  end

  def set_product
    @product = Product.find(params[:id])
    rescue ActiveRecord::RecordNotFound => error
      render json: error.message, status: :unauthorized
  end

  def check_input_for_purchase
    @amount = params["product"]["amount"]
    @product = Product.find(params[:id])
  end


  def calculate_output
    #remove one product from DB
    @product.update(amountAvailable: @product.amountAvailable - 1)
    #update user deposit and spent
    spent = @product.cost
    current_user.update(deposit: @deposit - @product.cost)
    change = @deposit - @product.cost
    #calculate number of coins in change
    change_hash = calc_change(change)
    #json with info
    render json: { message: "Purchase Completed!",data: {
      spent: spent,
      productName: @product.productName,
      change: change_hash
    }, status: "success" }, status: :ok
  end

  def calc_change(change)
    # initialize a hash to store the number of coins for each denomination
    coins = { 5 => 0, 10 => 0, 20 => 0, 50 => 0, 100 => 0 }

    # calculate the number of each denomination coin to return as change
    while change.cents >= 100
      change -= Money.new(100)
      coins[100] += 1
    end

    while change.cents >= 50
      change -= Money.new(50)
      coins[50] += 1
    end

    while change.cents >= 20
      change -= Money.new(20)
      coins[20] += 1
    end

    while change.cents >= 10
      change -= Money.new(10)
      coins[10] += 1
    end

    while change.cents >= 5
      change -= Money.new(5)
      coins[5] += 1
    end
    result = {}
    coins.each do |key, value|
      result["#{key}cents"] = value if value > 0
    end
  end

  def check_login
    unless user_signed_in?
      render json: { message: "Not logged in", status: "failed" }, status: :unprocessable_entity
      return
    end
  end
end
