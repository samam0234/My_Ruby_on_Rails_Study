module Api
  module V1
    class CommentsController < BaseController
      before_action :require_login, only: %i[create destroy]
      before_action :set_post

      def index
        @comments = @post.comments.includes(:user).order(created_at: :asc)
      end

      def create
        @comment = @post.comments.build(comment_params.merge(user: current_user))
        if @comment.save
          render :show, status: :created
        else
          render json: { errors: @comment.errors.to_hash(true) }, status: :unprocessable_entity
        end
      end

      def destroy
        comment = @post.comments.find(params[:id])
        unless comment.user_id == current_user.id
          render json: { error: "작성자만 댓글을 삭제할 수 있습니다." }, status: :forbidden
          return
        end

        comment.destroy
        head :no_content
      end

      private

      def set_post
        @post = Post.find(params[:post_id])
      end

      def comment_params
        params.require(:comment).permit(:body)
      end
    end
  end
end
