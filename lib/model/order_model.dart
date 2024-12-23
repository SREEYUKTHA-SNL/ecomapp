class Order {
  final int customerId;
  final String orderDate;
  final double totalAmount;
  final List<ProductOrder> orderDetails;

  Order({
    required this.customerId,
    required this.orderDate,
    required this.totalAmount,
    required this.orderDetails,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      customerId: json['customerid']??0,
      orderDate: json['orderDate']??'date',
      totalAmount: json['netAmount']?? 0,
      orderDetails: (json['orderDetails'] as List<dynamic>?)
              ?.map((item) => ProductOrder.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class ProductOrder {
  final int productId;
  final int quantity;
  final double total;

  ProductOrder({
    required this.productId,
    required this.quantity,
    required this.total,
  });

  factory ProductOrder.fromJson(Map<String, dynamic> json) {
    return ProductOrder(
      productId: json['productId']??0,
      quantity: json['quantity']??0,
      total: json['totalAmount']??0 ,
    );
  }
}
