// ignore_for_file: deprecated_member_use, unused_element, library_private_types_in_public_api, avoid_print, unused_local_variable

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
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
          'gradientColors': [const Color(0xFF4A90E2), const Color(0xFFA3BFFA)],
          'primaryColor': const Color(0xFF4A90E2)
        },
        {
          'name': 'Dark Blue',
          'gradientColors': [const Color(0xFF2C5282), const Color(0xFF63B3ED)],
          'primaryColor': const Color(0xFF63B3ED)
        },
        {
          'name': 'Purple',
          'gradientColors': [const Color(0xFF6B46C1), const Color(0xFFD6BCFA)],
          'primaryColor': const Color(0xFF6B46C1)
        },
        {
          'name': 'Orange',
          'gradientColors': [const Color(0xFFF6AD55), const Color(0xFFFDBA74)],
          'primaryColor': const Color(0xFFF6AD55)
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Xác nhận xóa',
          style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
        ),
        content: const Text(
          'Bạn có chắc muốn xóa giao dịch này?',
          style: TextStyle(fontFamily: 'Roboto'),
        ),
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
                  backgroundColor: Color(0xFFFF2D55),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF2D55),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Có',
                style: TextStyle(
                  fontFamily: 'Roboto',
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
        'gradientColors': [const Color(0xFF4A90E2), const Color(0xFFA3BFFA)],
        'primaryColor': const Color(0xFF4A90E2)
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              color: const Color(0xFF6366F1),
              child: const Center(
                child: Text(
                  'Giao dịch',
                  style: TextStyle(
                    fontFamily: 'Roboto',
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
                            size: 48,
                            color: const Color(0xFF6366F1).withOpacity(0.6),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Chưa có giao dịch nào',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Thêm giao dịch để bắt đầu!',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: Colors.grey.shade500,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      itemCount: widget.danhSachGiaoDich.length,
                      itemBuilder: (context, index) {
                        final giaoDich = widget.danhSachGiaoDich[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: giaoDich.loai == 'Thu nhập'
                                      ? const Color(0xFFCCF6D4).withOpacity(0.5)
                                      : const Color(0xFFFADADD).withOpacity(0.5),
                                  child: Icon(
                                    giaoDich.loai == 'Thu nhập'
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: giaoDich.loai == 'Thu nhập'
                                        ? const Color(0xFF34C759)
                                        : const Color(0xFFFF2D55),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        giaoDich.moTa,
                                        style: const TextStyle(
                                          fontFamily: 'Roboto',
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        DateFormat('HH:mm • dd/MM').format(giaoDich.ngayGio),
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${giaoDich.loai == 'Thu nhập' ? '+' : '-'}${giaoDich.soTien.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        color: giaoDich.loai == 'Thu nhập'
                                            ? const Color(0xFF34C759)
                                            : const Color(0xFFFF2D55),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => showXoaGiaoDichDialog(index),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Color(0xFFFF2D55),
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}