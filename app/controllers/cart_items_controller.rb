class CartItemsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_customer_cart
    before_action :set_cart_item, only: [:update, :destroy]

    def create
        product = Product.find_by(id: cart_item_params[:product_id])
        quantity = cart_item_params[:quantity].to_i

        unless product && quantity.positive?
        redirect_to products_path,
                    alert: "商品または数量が正しくありません。"
        return
        end

        cart_item = @cart.cart_items.find_or_initialize_by(
        product: product
        )

        cart_item.quantity = cart_item.quantity.to_i + quantity

        if cart_item.save
        redirect_to cart_path(@cart),
                    notice: "商品がカートに追加されました。"
        else
        redirect_to product_path(product),
                    alert: "商品をカートに追加できませんでした。"
        end
    end

    def update
        quantity = cart_item_params[:quantity].to_i

        if quantity <= 0
        @cart_item.destroy!
        redirect_to cart_path(@cart),
                    notice: "商品がカートから削除されました。"
        elsif @cart_item.update(quantity: quantity)
        redirect_to cart_path(@cart),
                    notice: "商品数量が更新されました。"
        else
        redirect_to cart_path(@cart),
                    alert: "商品数量の更新に失敗しました。"
        end
    end

    def destroy
        @cart_item.destroy!
        redirect_to cart_path(@cart),
                    notice: "商品がカートから削除されました。"
    end

    private

    def set_customer_cart
        return redirect_to root_path if current_user.admin_flg?

        @cart = current_user.cart || current_user.create_cart!
    end

    def set_cart_item
        @cart_item = @cart.cart_items.find(params[:id])
    end

    def cart_item_params
        params.require(:cart_item).permit(:product_id, :quantity)
    end
end
