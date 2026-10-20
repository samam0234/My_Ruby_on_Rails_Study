module Api
  module V1
    class BaseController < ApplicationController
      skip_forgery_protection

      private

      def require_login
        return if current_user

        render json: { error: "로그인이 필요합니다." }, status: :unauthorized
      end
    end
  end
end
