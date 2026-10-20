class ApiToken
  ALGORITHM = "HS256"
  TTL = 12.hours

  def self.secret
    ENV["JWT_SECRET"].presence || Rails.application.secret_key_base
  end

  def self.encode(user)
    JWT.encode({ "sub" => user.id, "exp" => TTL.from_now.to_i }, secret, ALGORITHM)
  end

  def self.user_from(token)
    payload, = JWT.decode(token, secret, true, { algorithm: ALGORITHM })
    User.find_by(id: payload["sub"])
  rescue JWT::DecodeError
    nil
  end
end
