class ApplicationController < ActionController::API
  include Devise::Controllers::Helpers

  def authenticate_user!
    jwt_token = request.headers['Authorization']&.split(' ')&.last
    if jwt_token
      begin
        decoded_token =
          JWT.decode(
            jwt_token,
            ENV.fetch('JWT_SECRET_KEY', 'test'),
            true,
            algorithm: 'HS256'
          )
        user_id = decoded_token[0]['sub'] # 'sub' usually contains user_id
        @current_user = User.find_by!(id: user_id, suspended: false)
      rescue JWT::ExpiredSignature
        render json: { error: 'Token has expired' }, status: :unauthorized
      rescue JWT::DecodeError
        render json: { error: 'Invalid token' }, status: :unauthorized
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :unauthorized
      end
    else
      render json: { error: 'Token not provided' }, status: :unauthorized
    end
  end
end
