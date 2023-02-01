class Users::SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    if resource.email == params[:user][:email] && resource.role == params[:user][:role]
      render json: { message: 'You are logged in.' }, data: UserSerializer.new(resource).serializable_hash[:data][:attributes], status: :ok
    else
      render json: { message: 'The resource is not the same as the request, logout first.' }, status: :unprocessable_entity
    end
  end



  def respond_to_on_destroy
    jwt_payload = JWT.decode(request.headers['Authorization'].split(' ')[1],
    Rails.application.credentials.fetch(:devise)[:jwt_secret_key]).first
    p jwt_payload
    p jwt_payload['sub']
    current_user = User.find(jwt_payload['sub'])
    log_out_success && return if current_user

    log_out_failure
  end

  def log_out_success
    render json: { message: "You are logged out." }, status: :ok
  end

  def log_out_failure
    render json: { message: "Hmm nothing happened."}, status: :unauthorized
  end
end
