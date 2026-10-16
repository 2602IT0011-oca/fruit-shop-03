class CartsController < ApplicationController
  def show
    return redirect_to root_path unless user_signed_in?
    return redirect_to products_path if current_user.admin_flg?

    @cart = current_user.cart
    user_cart_calculation
  end

  def index
    session[:cart] ||= []

    product_ids = session[:cart].map { |item| item["id"].to_i }

    @products = Product.where(id: product_ids).index_by(&:id)

    # Recalculate totals using current product prices
    cart_calculation
  end

  def add_product
    session[:cart] ||= []

    product = Product.find(cart_params[:product_id])
    count = cart_params[:count].to_i

    if count <= 0
      redirect_to product_path(product),
                  alert: "数量は1以上にしてください。"
      return
    end

    item = session[:cart].find do |cart_item|
      cart_item["id"].to_i == product.id
    end

    if item
      item["count"] = item["count"].to_i + count
    else
      session[:cart] << {
        "id" => product.id,
        "count" => count
      }
    end

    cart_calculation

    redirect_to carts_path,
                notice: "商品がカートに追加されました。"
  end

  def update_quantity
    session[:cart] ||= []

    product_id = params[:id].to_i
    count = params[:count].to_i

    item = session[:cart].find do |cart_item|
      cart_item["id"].to_i == product_id
    end

    if item
      if count <= 0
        session[:cart].delete(item)
      else
        item["count"] = count
      end
    end

    cart_calculation

    redirect_to carts_path,
                notice: "カートを更新しました。"
  end

  def remove_item
    session[:cart] ||= []

    product_id = params[:id].to_i

    session[:cart].delete_if do |item|
      item["id"].to_i == product_id
    end

    cart_calculation

    redirect_to carts_path,
                notice: "商品がカートから削除されました。"
  end

  private

  def cart_params
    params.permit(:product_id, :count)
  end
end
