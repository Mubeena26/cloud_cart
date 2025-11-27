class ProductEntity {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String image;

  ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
  });

  // ---------- FROM JSON ----------
  factory ProductEntity.fromJson(Map<String, dynamic> json) {
    return ProductEntity(
      id: json['id'].toString(),
      name: json['name'] ?? "",
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] as double),
      quantity: json['quantity'] ?? 0,
      // Try different possible column names for image
      image: json['images'] ??
             json['image'] ?? 
             json['imageUrl'] ?? 
             json['image_url'] ?? 
             json['photo'] ?? 
             json['photoUrl'] ?? 
             "",
    );
  }

  // ---------- TO JSON ----------
  Map<String, dynamic> toJson() {
    return {
      'id': id, // optional on insert
      'name': name,
      'price': price,
      'quantity': quantity,
      'image': image,
    };
  }
}
