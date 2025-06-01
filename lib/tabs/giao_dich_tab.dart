// ignore_for_file: deprecated_member_use, unused_element, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/giao_dich.dart';

class GiaoDichTab extends StatefulWidget {
  final List<GiaoDich> danhSachGiaoDich;
  final Function(GiaoDich) onThemGiaoDich;
  final Function(int) onXoaGiaoDich;
  final List<Map<String, dynamic>> danhSachKhoanSoDu;
  final Function(GiaoDich, int) onEdit;
  final Function(int) onDelete;
  final VoidCallback onRefresh;

  const GiaoDichTab({
    super.key,
    required this.danhSachGiaoDich,
    required this.onThemGiaoDich,
    required this.onXoaGiaoDich,
    required this.danhSachKhoanSoDu,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  _GiaoDichTabState createState() => _GiaoDichTabState();
}

class _GiaoDichTabState extends State<GiaoDichTab> {
  String _selectedTheme = 'Light Teal';
  List<Map<String, dynamic>> _themes = [];
  bool _isLoading = true;
  String _currentUserPhone = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUserPhone();
  }

  Future<void> _loadCurrentUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserPhone = prefs.getString('currentUserPhone') ?? '';
      _loadTheme();
      _loadDanhSachGiaoDich();
    });
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themes = [
        {
          'name': 'Light Teal',
          'gradientColors': [const Color(0xFF40C4FF), const Color(0xFF81D4FA)],
          'primaryColor': const Color(0xFF40C4FF)
        },
        {
          'name': 'Dark Blue',
          'gradientColors': [const Color(0xFF2C3E50), const Color(0xFF3498DB)],
          'primaryColor': const Color(0xFF3498DB)
        },
        {
          'name': 'Purple',
          'gradientColors': [const Color(0xFF6B48FF), const Color(0xFFAB6AFF)],
          'primaryColor': const Color(0xFF6B48FF)
        },
        {
          'name': 'Orange',
          'gradientColors': [const Color(0xFFFFA726), const Color(0xFFFF7043)],
          'primaryColor': const Color(0xFFFFA726)
        },
      ];
      _selectedTheme = prefs.getString('${_currentUserPhone}_selectedTheme') ?? 'Light Teal';
    });
  }

  Future<void> _loadDanhSachGiaoDich() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('${_currentUserPhone}_danh_sach_giao_dich');
    List<GiaoDich> loadedGiaoDich = [];

    if (savedData != null) {
      try {
        final dynamic decodedData = jsonDecode(savedData);
        if (decodedData is List) {
          loadedGiaoDich = decodedData.map((json) {
            final Map<String, dynamic> giaoDichJson = json is Map ? json : jsonDecode(json as String);
            return GiaoDich.fromJson(giaoDichJson);
          }).toList();
        }
      } catch (e) {
        print('Lỗi khi parse JSON: $e');
        // Đặt danh sách giao dịch rỗng nếu có lỗi
        loadedGiaoDich = [];
      }
    }
    setState(() {
      widget.danhSachGiaoDich.clear();
      widget.danhSachGiaoDich.addAll(loadedGiaoDich);
      _isLoading = false;
    });
  }

  Future<void> saveDanhSachGiaoDich() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> giaoDichList = widget.danhSachGiaoDich.map((giaoDich) {
      return giaoDich.toJson();
    }).toList();
    await prefs.setString('${_currentUserPhone}_danh_sach_giao_dich', jsonEncode(giaoDichList));
  }

  void showXoaGiaoDichDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa giao dịch này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không', style: TextStyle(color: Colors.grey)),
          ),
          GestureDetector(
            onTap: () {
              widget.onXoaGiaoDich(index);
              widget.onDelete(index);
              saveDanhSachGiaoDich();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa giao dịch!'),
                  backgroundColor: Color(0xFFEF5350),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF5350), Color(0xFFE53935)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                'Có',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentTheme = _themes.firstWhere(
      (t) => t['name'] == _selectedTheme,
      orElse: () => {
        'name': 'Light Teal',
        'gradientColors': [const Color(0xFF40C4FF), const Color(0xFF81D4FA)],
        'primaryColor': const Color(0xFF40C4FF)
      },
    );

    return Container(
      color: const Color(0xFFF5F7FA),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF40C4FF), Color(0xFF81D4FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Text(
                'Giao dịch',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: widget.danhSachGiaoDich.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 50,
                          color: currentTheme['primaryColor'],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Chưa có giao dịch nào',
                          style: TextStyle(
                            color: Color(0xFF616161),
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.danhSachGiaoDich.length,
                    itemBuilder: (context, index) {
                      final giaoDich = widget.danhSachGiaoDich[index];
                      final ngayHienThi =
                          '${giaoDich.ngayGio.day.toString().padLeft(2, '0')}/${giaoDich.ngayGio.month.toString().padLeft(2, '0')}/${giaoDich.ngayGio.year} ${giaoDich.ngayGio.hour.toString().padLeft(2, '0')}:${giaoDich.ngayGio.minute.toString().padLeft(2, '0')}';

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
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
                                    color: giaoDich.loai == 'Chi tiêu'
                                        ? const Color(0xFFEF5350).withOpacity(0.5)
                                        : const Color(0xFF4CAF50).withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    giaoDich.loai == 'Chi tiêu' ? Icons.arrow_downward : Icons.arrow_upward,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        giaoDich.moTa,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF212121),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Ngày: $ngayHienThi',
                                        style: const TextStyle(fontSize: 14, color: Color(0xFF616161)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Nhóm: ${giaoDich.nhom}',
                                        style: const TextStyle(fontSize: 14, color: Color(0xFF616161)),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${giaoDich.soTien.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: giaoDich.loai == 'Chi tiêu'
                                            ? const Color(0xFFEF5350)
                                            : const Color(0xFF4CAF50),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () => showXoaGiaoDichDialog(index),
                                      child: const Icon(Icons.delete, color: Color(0xFFEF5350), size: 20),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}