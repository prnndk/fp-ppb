import 'package:flutter/material.dart';
import 'package:final_project_ppb/models/menu.dart';

class MenuCard extends StatelessWidget {
  final MenuItem menuItem;
  final Function(MenuItem, int) onQuantityChanged;
  final int currentQuantity;

  const MenuCard({
    super.key,
    required this.menuItem,
    required this.onQuantityChanged,
    required this.currentQuantity,
  });

  void _incrementQuantity() {
    onQuantityChanged(menuItem, currentQuantity + 1);
  }

  void _decrementQuantity() {
    if (currentQuantity > 0) {
      onQuantityChanged(menuItem, currentQuantity - 1);
    }
  }

  String _formatPrice(double price) {
    double rupiahPrice = price * 100;
    return 'Rp ${rupiahPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Menu Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[300],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                menuItem.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 40,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Menu Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menuItem.name,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  menuItem.description ?? 'No description available',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    color: Color(0xFF643F04),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Price
                Text(
                  _formatPrice(menuItem.price),
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B4513),
                  ),
                ),

                const SizedBox(height: 12),

                // Counter
                Row(
                  children: [
                    GestureDetector(
                      onTap: _decrementQuantity,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B4513),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),

                    Container(
                      width: 50,
                      height: 32,
                      alignment: Alignment.center,
                      child: Text(
                        currentQuantity
                            .toString(), // Use currentQuantity instead of local state
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: _incrementQuantity,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B4513),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
