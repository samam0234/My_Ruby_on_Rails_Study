module Api
  module V1
    class SessionsController < BaseController
      def create
        user = User.find_by(email: params[:email].to_s.strip.downcase)
        unless user&.authenticate(params[:password])
          render json: { error: "이메일 또는 비밀번호가 올바르지 않습니다." }, status: :unauthorized
          return
        end

        render json: {
          token: ApiToken.encode(user),
          user: { id: user.id, email: user.email, nickname: user.nickname }
        }
      end
    end
  end
end
