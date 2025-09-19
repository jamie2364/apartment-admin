class InventoryItem {
  final int id;
  final String name;
  final String url;
  String stock;
  String imageUrl;
  final String apartmentId; // NEW FIELD

  InventoryItem({
    required this.id,
    required this.name,
    required this.url,
    required this.stock,
    required this.imageUrl,
    required this.apartmentId,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      url: json['url'] ?? '',
      stock: (json['stock'] ?? '0').toString(),
      imageUrl: json['image_url'] ?? '',
      apartmentId: json['apartmentId'] ?? '', // NEW FIELD
    );
  }
}
