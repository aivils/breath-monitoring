module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      env["warden"]&.user || user_from_jwt || reject_unauthorized_connection
    end

    def user_from_jwt
      token = request.params[:token] || bearer_token
      return if token.blank?

      payload = Warden::JWTAuth::TokenDecoder.new.call(token)
      User.find_by(id: payload["sub"])
    rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError
      nil
    end

    def bearer_token
      auth = request.headers["Authorization"]
      return unless auth.present?

      auth[/\ABearer (.+)\z/, 1]
    end
  end
end
