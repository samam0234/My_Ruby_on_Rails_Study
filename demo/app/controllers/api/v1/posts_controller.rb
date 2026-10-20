module Api
  module V1
    class PostsController < BaseController
      before_action :require_login, only: %i[create update destroy]
      before_action :set_post, only: %i[show update destroy]

      def index
        @posts = Post.includes(:user).order(created_at: :desc)
      end

      def show
        @comments = @post.comments.includes(:user).order(created_at: :asc)
      end

      def create
        @post = current_user.posts.build(post_params)
        if @post.save
          render :show, status: :created
        else
          render json: { errors: @post.errors.to_hash(true) }, status: :unprocessable_entity
        end
      end

      def update
        return unless author?

        if @post.update(post_params)
          render :show
        else
          render json: { errors: @post.errors.to_hash(true) }, status: :unprocessable_entity
        end
      end

      def destroy
        return unless author?

        @post.destroy
        head :no_content
      end

      private

      def set_post
        @post = Post.find(params[:id])
      end

      def post_params
        params.require(:post).permit(:title, :body)
      end

      def author?
        return true if @post.user_id == current_user.id

        render json: { error: "작성자만 수정하거나 삭제할 수 있습니다." }, status: :forbidden
        false
      end
    end
  end
end
