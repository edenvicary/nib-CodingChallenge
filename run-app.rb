require "json"

class OrderFulfilment 
  def initialize
    file = File.open "data.json"  
    data = JSON.load file
    @products = ProductStore.new(data['products'])
    @orders = OrderStore.new(data['orders'])
    file.close
  end

  def proccessOrders(requestedOrders)
    unfulfilable = []
    for orderNum in requestedOrders do
      order = @orders.get(orderNum)

      isEnoughStock = true
      for item in order["items"] do
        product = @products.get(item["productId"])
        if product["quantityOnHand"] - item["quantity"] < 0
          isEnoughStock = false
        end
      end

      if isEnoughStock
        for item in order["items"] do
          @products.reduceQuantity(item["productId"], item["quantity"])
          if product["quantityOnHand"] - item["quantity"] - product["reorderThreshold"] < 0
            reorderStock(product["productId"])
          end
        end
      else
        unfulfilable.append(orderNum)
        @orders.updateStatus(item["orderId"], "Unfulfillable")
      end
    end
    unfulfilable
  end

  private

  def reorderStock(productId)
    # Stub as requested
  end
end

class ProductStore
  def initialize(products)
    @products = {}
    products.each { |p| @products[p["productId"]] = p }
  end

  def get(productId)
    @products[productId]
  end

  def reduceQuantity(productId, quantityReduction)
    @products[productId]["quantityOnHand"] -= quantityReduction
  end
end

class OrderStore
  def initialize(orders)
    @orders = {}
    orders.each { |o| @orders[o["orderId"]] = o }
  end
  
  def get(orderId)
    @orders[orderId]
  end

  def updateStatus(orderId, status)
    @orders[orderId]["status"] = status
  end
end

fulfiler = OrderFulfilment.new
orders = [1122, 1123, 1124, 1125]
puts fulfiler.proccessOrders(orders)