class InventoryItemModel {
  final String id;
  final String name;
  final int quantity;
  final int minThreshold;
  final String supplierInfo;

  InventoryItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.minThreshold,
    required this.supplierInfo,
  });

  bool get isLowStock => quantity <= minThreshold;

  factory InventoryItemModel.fromMap(String id, Map<String, dynamic> data) {
    return InventoryItemModel(
      id: id,
      name: data['name'] ?? '',
      quantity: data['quantity']?.toInt() ?? 0,
      minThreshold: data['minThreshold']?.toInt() ?? 5,
      supplierInfo: data['supplierInfo'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'minThreshold': minThreshold,
      'supplierInfo': supplierInfo,
    };
  }
}
