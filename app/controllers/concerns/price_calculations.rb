module PriceCalculations
  # Calculate one item's subtotal
  def calculate_item_total(price, count)
    price * count
  end

  # Calculate the grand total
  def calculate_total_sum(items)
    items.sum
  end

  # Recalculate the session cart
  def cart_calculation
    session[:cart] ||= []

    session[:cart].each do |item|
      product = Product.find(item["id"].to_i)

      item["price"] = product.price
      item["item_price"] =
        calculate_item_total(item["price"], item["count"])
    end

    session[:cart_total] =
      calculate_total_sum(
        session[:cart].map { |item| item["item_price"] }
      )
  end

  def user_cart_calculation
    cart = current_user.cart

    if cart.nil?
        @item_totals = []
        @cart_total = 0
        return
    end

    @item_totals = cart.cart_items.includes(:product).map do |item|
        calculate_item_total(item.product.price, item.quantity)
    end

    @cart_total = calculate_total_sum(@item_totals)
    end
end