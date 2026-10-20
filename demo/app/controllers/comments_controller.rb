class CommentsController < ApplicationController
  before_action :set_post

  def create
    @comment = @post.comments.build(comment_params)
    if @comment.save
      redirect_to @post, notice: "댓글을 남겼습니다."
    else
      @comments = @post.comments.includes(:user).order(created_at: :asc)
      render "posts/show", status: :unprocessable_entity
    end
  end

  def destroy
    @post.comments.find(params[:id]).destroy
    redirect_to @post, notice: "댓글을 삭제했습니다."
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
