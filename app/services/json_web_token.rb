class JsonWebToken
  # JWT Secret key from Rails credentials
  SECRET_KEY = Rails.application.credentials.jwt_secret_key || Rails.application.secret_key_base

  # Token expiration time (24 hours)
  EXPIRATION_TIME = 24.hours.from_now.to_i

  # Encode payload to JWT token
  def self.encode(payload, exp = EXPIRATION_TIME)
    payload[:exp] = exp
    payload[:jti] = SecureRandom.uuid  # Unique token ID
    JWT.encode(payload, SECRET_KEY, "HS256")
  end

  # Decode JWT token
  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" })
    payload = HashWithIndifferentAccess.new(decoded[0])

    # Check if token is blacklisted
    raise ExceptionHandler::InvalidToken if BlacklistedToken.blacklisted?(token)

    payload
  rescue JWT::ExpiredSignature
    raise ExceptionHandler::ExpiredSignature
  rescue JWT::DecodeError
    raise ExceptionHandler::DecodeError
  end
end
