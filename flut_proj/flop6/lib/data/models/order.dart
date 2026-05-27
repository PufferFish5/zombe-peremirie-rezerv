class Order {
  final int id;
  final int userId;
  final int drinkId;
  final int quantity;
  final String status;
  final DateTime createdAt;

  final String drinkName;
  final String drinkSeries;
  final double drinkPrice;
  final String drinkImage;

  const Order({
    required this.id,
    required this.userId,
    required this.drinkId,
    required this.quantity,
    required this.status,
    required this.createdAt,
    required this.drinkName,
    required this.drinkSeries,
    required this.drinkPrice,
    required this.drinkImage,
  });

  factory Order.fromMap(Map<String, dynamic> map) => Order(
    id:            map['id']             as int,
    userId:        map['user_id']        as int,
    drinkId:     map['drink_id']     as int,
    quantity:      map['quantity']       as int,
    status:        map['status']         as String,
    createdAt:     DateTime.parse(map['created_at'] as String),
    drinkName:   map['drink_name']   as String? ?? '',
    drinkSeries: map['drink_series'] as String? ?? '',
    drinkPrice:  (map['drink_price'] as num?)?.toDouble() ?? 0.0,
    drinkImage:  map['drink_image']  as String? ?? '',
  );
}