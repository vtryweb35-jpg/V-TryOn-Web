class OrderItem {
  final String name;
  final int qty;
  final String image;
  final double price;
  final String product;

  OrderItem({
    required this.name,
    required this.qty,
    required this.image,
    required this.price,
    required this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'],
      qty: json['qty'],
      image: json['image'],
      price: json['price'].toDouble(),
      product: json['product'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'qty': qty,
      'image': image,
      'price': price,
      'product': product,
    };
  }
}

class Order {
  final String id;
  final List<OrderItem> orderItems;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final bool isPaid;
  final bool isDelivered;

  final String? userName;
  final String? userEmail;

  Order({
    required this.id,
    required this.orderItems,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.isPaid,
    required this.isDelivered,
    this.userName,
    this.userEmail,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      orderItems: (json['orderItems'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      totalPrice: json['totalPrice'].toDouble(),
      status: json['status'] ?? 'Processing',
      createdAt: DateTime.parse(json['createdAt']),
      isPaid: json['isPaid'] ?? false,
      isDelivered: json['isDelivered'] ?? false,
      userName: json['user'] is Map ? json['user']['name'] : null,
      userEmail: json['user'] is Map ? json['user']['email'] : null,
    );
  }
}
