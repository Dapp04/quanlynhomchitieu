// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

Widget buildFilterButton({
  required AnimationController animationController,
  required Animation<double> scaleAnimation,
  required String title,
  required bool isSelected,
  required VoidCallback onTap,
  required List<Map<String, dynamic>> themes,
  required String selectedTheme,
}) {
  final _ = themes.isNotEmpty
      ? themes.firstWhere(
          (t) => t['name'] == selectedTheme,
          orElse: () => {
            'name': 'Light Teal',
            'gradientColors': [const Color(0xFF40C4FF), const Color(0xFF81D4FA)],
            'primaryColor': const Color(0xFF40C4FF)
          },
        )
      : {
          'name': 'Light Teal',
          'gradientColors': [const Color(0xFF40C4FF), const Color(0xFF81D4FA)],
          'primaryColor': const Color(0xFF40C4FF)
        };

  return GestureDetector(
    onTapDown: (_) => animationController.forward(),
    onTapUp: (_) => animationController.reverse(),
    onTapCancel: () => animationController.reverse(),
    onTap: onTap,
    child: ScaleTransition(
      scale: scaleAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF40C4FF), Color(0xFF81D4FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF212121),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    ),
  );
}

Widget buildSummaryCard({
  required String title,
  required double value,
  required Color color,
  required IconData icon,
  required bool isVisible,
}) {
  return Expanded(
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildLargestItemCard({
  required String title,
  required double value,
  required Color color,
  required IconData icon,
}) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF616161),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildGroupBar({
  required BuildContext context,
  required String groupName,
  required double amount,
  required double maxAmount,
  required bool isChiTieu,
}) {
  // Tính chiều rộng tối đa của thanh dựa trên chiều rộng màn hình
  final double maxWidth = MediaQuery.of(context).size.width - 32 - 24; // Trừ padding và margin
  const double minRatio = 0.1; // Tỷ lệ tối thiểu để thanh vẫn hiển thị rõ ràng

  // Tính tỷ lệ độ dài của thanh
  double ratio = amount / maxAmount;
  // Đảm bảo thanh có độ dài tối thiểu hợp lý ngay cả khi amount nhỏ
  ratio = ratio < minRatio ? minRatio : ratio;
  double barWidth = maxWidth * ratio;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    groupName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
                Text(
                  '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ',
                  style: TextStyle(
                    fontSize: 14,
                    color: isChiTieu ? const Color(0xFFEF5350) : const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 8,
              width: barWidth,
              decoration: BoxDecoration(
                color: isChiTieu ? const Color(0xFFEF5350) : const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}