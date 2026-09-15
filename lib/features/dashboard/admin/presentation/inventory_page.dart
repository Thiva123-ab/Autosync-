import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../shared/inventory_repository.dart';
import '../../../../core/models/inventory_item_model.dart';

final inventoryListProvider = StreamProvider.autoDispose<List<InventoryItemModel>>((ref) {
  return ref.watch(inventoryRepositoryProvider).getInventoryStream();
});

class InventoryPage extends ConsumerWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryListProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent, // Uses parent's gradient
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context, ref),
        backgroundColor: const Color(0xFF00C6FF),
        foregroundColor: Colors.black87,
        icon: const Icon(Icons.add_box),
        label: const Text('Add Part', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: inventoryAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  Text('Inventory is empty.', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 18)),
                ],
              ).animate().fade().scale(),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20.0).copyWith(bottom: 100),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildInventoryCard(context, ref, item, index, theme, isDark);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00C6FF))),
        error: (error, stack) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }

  Widget _buildInventoryCard(BuildContext context, WidgetRef ref, InventoryItemModel item, int index, ThemeData theme, bool isDark) {
    final isLow = item.isLowStock;
    final cardColor = isLow ? Colors.redAccent.withValues(alpha: 0.1) : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.6));
    final borderColor = isLow ? Colors.redAccent.withValues(alpha: 0.5) : (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.05));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        color: cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(item.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                    ),
                    if (isLow)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.redAccent),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 14),
                            SizedBox(width: 4),
                            Text('LOW STOCK', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                       .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.1, 1.1), duration: 1.seconds, curve: Curves.easeInOut),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Supplier: ${item.supplierInfo}', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('IN STOCK', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                        Text(
                          '${item.quantity}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isLow ? Colors.redAccent : const Color(0xFF00E676),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildQtyButton(
                          icon: Icons.remove,
                          color: Colors.orangeAccent,
                          isDark: isDark,
                          onPressed: () {
                            if (item.quantity > 0) {
                              ref.read(inventoryRepositoryProvider).updateQuantity(item.id, item.quantity - 1);
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildQtyButton(
                          icon: Icons.add,
                          color: const Color(0xFF00C6FF),
                          isDark: isDark,
                          onPressed: () {
                            ref.read(inventoryRepositoryProvider).updateQuantity(item.id, item.quantity + 1);
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(delay: (50 * index).ms).slideY(begin: 0.1);
  }

  Widget _buildQtyButton({required IconData icon, required Color color, required VoidCallback onPressed, required bool isDark}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '0');
    final thresholdCtrl = TextEditingController(text: '5');
    final supplierCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Add Inventory Item', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameCtrl, 'Part Name (e.g. Brake Pads)', context: context),
              const SizedBox(height: 12),
              _buildTextField(qtyCtrl, 'Initial Quantity', isNumber: true, context: context),
              const SizedBox(height: 12),
              _buildTextField(thresholdCtrl, 'Low Stock Alert Threshold', isNumber: true, context: context),
              const SizedBox(height: 12),
              _buildTextField(supplierCtrl, 'Supplier Info', context: context),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final item = InventoryItemModel(
                id: '',
                name: nameCtrl.text.trim(),
                quantity: int.tryParse(qtyCtrl.text) ?? 0,
                minThreshold: int.tryParse(thresholdCtrl.text) ?? 5,
                supplierInfo: supplierCtrl.text.trim(),
              );
              if (item.name.isNotEmpty) {
                ref.read(inventoryRepositoryProvider).addInventoryItem(item);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C6FF), foregroundColor: Colors.black),
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, required BuildContext context}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade600),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2))),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00C6FF))),
      ),
    );
  }
}
