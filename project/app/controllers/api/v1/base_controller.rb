module Api
  module V1
    class BaseController < ApplicationController
      skip_forgery_protection

      private

      def current_user
        return @current_user if defined?(@current_user)

        if request.authorization.present?
          @current_user = user_from_bearer
        else
          super
        end
      end

      def user_from_bearer
        scheme, token = request.authorization.to_s.split(" ", 2)
        return unless scheme&.casecmp("Bearer")&.zero? && token.present?

        ApiToken.user_from(token)
      end

      def require_login
        return if current_user

        render json: { error: "로그인이 필요합니다." }, status: :unauthorized
      end
    end
  end
end
