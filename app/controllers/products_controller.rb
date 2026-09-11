class ProductsController < ApplicationController
  def index
    @products = Product.all
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    
    if @product.save
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @product = Product.find(params[:id])
    if @product.nil?
      redirect_to root_path
  end

  def edit
    @product = Product.find(params[:id])
  end
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      redirect_to product_path(@product)
    else
      render :edit
    end
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to root_path
  end

  private

    def product_params
      params.require(:product).permit(:name, :description, :price)
    end

    # 管理者確認メソッド
    def check_admin
      unless current_user.admin_flg
        # 管理者でない場合、商品一覧ページにリダイレクト
        redirect_to products_path, alert: '管理者権限が必要です。'
      end
    end
end
