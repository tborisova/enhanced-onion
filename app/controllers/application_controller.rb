class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def authenticate_user!
    jwt_token = request.headers['Authorization']&.split(' ')&.last
    if jwt_token
      begin
        decoded_token =
          JWT.decode(
            jwt_token,
            Rails.application.credentials.devise.jwt_secret_key,
            true,
            algorithm: 'HS256'
          )
        user_id = decoded_token[0]['sub'] # 'sub' usually contains user_id
        @current_user = User.find(user_id)
      rescue JWT::ExpiredSignature
        render json: { error: 'Token has expired' }, status: :unauthorized
      rescue JWT::DecodeError
        render json: { error: 'Invalid token' }, status: :unauthorized
      end
    else
      render json: { error: 'Token not provided' }, status: :unauthorized
    end
  end
end
