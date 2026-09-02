import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/inventory_item_model.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(FirebaseFirestore.instance);
});

class InventoryRepository {
  final FirebaseFirestore _firestore;

  InventoryRepository(this._firestore);

  Stream<List<InventoryItemModel>> getInventoryStream() {
    return _firestore
        .collection('inventory')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryItemModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addInventoryItem(InventoryItemModel item) async {
    await _firestore.collection('inventory').add(item.toMap());
  }

  Future<void> updateQuantity(String id, int newQuantity) async {
    await _firestore.collection('inventory').doc(id).update({'quantity': newQuantity});
  }

  Future<void> deleteItem(String id) async {
    await _firestore.collection('inventory').doc(id).delete();
  }
}
