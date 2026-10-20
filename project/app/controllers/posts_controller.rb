class PostsController < ApplicationController
  before_action :require_login, except: %i[index show]
  before_action :set_post, only: %i[show edit update destroy]
  before_action :require_author, only: %i[edit update destroy]

  def index
    @posts, @total, @page, @per = Post.catalog(query: params[:q], page: params[:page], per: params[:per])
  end

  def show
    @comments = @post.comments.includes(:user).order(created_at: :asc)
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to @post, notice: "글을 저장했습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "글을 수정했습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: "글을 삭제했습니다."
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body)
  end

  def require_author
    return if @post.user_id == current_user.id

    redirect_to @post, alert: "작성자만 수정하거나 삭제할 수 있습니다."
  end
end
