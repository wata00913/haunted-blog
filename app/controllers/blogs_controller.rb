# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_current_user_blog, only: %i[edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show
    @blog = Blog.referable(current_user&.id).find(params[:id])
  end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    params = current_user.premium ? blog_params_by_premium : blog_params_by_non_premium
    @blog = current_user.blogs.new(params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    params = current_user.premium ? blog_params_by_premium : blog_params_by_non_premium
    if @blog.update(params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_current_user_blog
    @blog = current_user.blogs.find(params[:id])
  end

  def blog_params_by_non_premium
    params.require(:blog).permit(:title, :content)
  end

  def blog_params_by_premium
    params.require(:blog).permit(:title, :content, :secret, :random_eyecatch)
  end
end
