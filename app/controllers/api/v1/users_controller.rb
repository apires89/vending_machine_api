class Api::V1::UsersController < Api::V1::BaseController
  def deposit
    valid_deposit_amount ? check_and_update_deposit : render_something_went_wrong
  end

  def reset
    # reset deposit back to zero
    if current_user.role == "buyer" && current_user.update(deposit: 0)
        render json: current_user, status: :ok
    else
        render json: { message: "Not a buyer, or something went wrong.", data: current_user.errors.full_messages, status: "failed" }, status: :unprocessable_entity
    end
  end

  def start_selling
    current_user.change_user_to_seller
    render json: current_user, status: :ok
  end

  private

  def check_and_update_deposit
    if current_user.role == "buyer" && current_user.update(deposit: current_user.deposit + convert_to_cents)
        render json: current_user, status: :ok
    else
        render json: { message: "Not a customer, or something went wrong.", data: current_user.errors.full_messages, status: "failed" }, status: :unprocessable_entity
    end
  end

  def render_something_went_wrong
    render json: { message: "Wrong input, only accepts 5, 10 ,20 ,50 or 100 cents", data: current_user.errors.full_messages, status: "failed input" }, status: :unprocessable_entity
  end


  def deposit_params
    params.require(:user).permit(:deposit)
  end

  def convert_to_cents
    Money.new(deposit_params[:deposit])
  end

  def valid_deposit_amount
    valid_amount = [5,10,20,50,100]
    valid_amount.include?(deposit_params["deposit"].to_i)
  end
end
