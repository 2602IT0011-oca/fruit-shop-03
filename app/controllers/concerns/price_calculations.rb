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
end