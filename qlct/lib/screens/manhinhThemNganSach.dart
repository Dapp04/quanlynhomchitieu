// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ManHinhThemNganSach extends StatefulWidget {
  final String currentUserPhone;
  final List<String> danhSachNhomChiTieu;
  final Map<String, double> nganSachNhomChiTieu;
  final Function(Map<String, double>) onSave;

  const ManHinhThemNganSach({
    super.key,
    required this.currentUserPhone,
    required this.danhSachNhomChiTieu,
    required this.nganSachNhomChiTieu,
    required this.onSave,
  });

  @override
  State<ManHinhThemNganSach> createState() => _ManHinhThemNganSachState();
}

class _ManHinhThemNganSachState extends State<ManHinhThemNganSach> {
  String? _nhomDuocChon;
  final TextEditingController _boDieuKhienNganSach = TextEditingController();

  // Khởi tạo trạng thái ban đầu
  @override
  void initState() {
    super.initState();
    _nhomDuocChon = widget.danhSachNhomChiTieu.isNotEmpty ? widget.danhSachNhomChiTieu.first : null;
    if (_nhomDuocChon != null) {
      _boDieuKhienNganSach.text = (widget.nganSachNhomChiTieu[_nhomDuocChon] ?? 0.0).toStringAsFixed(0);
    }

    // Định dạng số tiền nhập vào
    _boDieuKhienNganSach.addListener(() {
      final text = _boDieuKhienNganSach.text.replaceAll('.', '');
      if (text.isEmpty) return;
      final number = double.tryParse(text) ?? 0;
      final formatted = number.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
      if (_boDieuKhienNganSach.text != formatted) {
        _boDieuKhienNganSach.value = _boDieuKhienNganSach.value.copyWith(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    });
  }

  // Lưu ngân sách vào SharedPreferences và gọi callback
  Future<void> _saveNganSach() async {
    if (_nhomDuocChon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn nhóm!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final String rawText = _boDieuKhienNganSach.text.replaceAll('.', '');
    final double nganSach = double.tryParse(rawText) ?? 0.0;

    if (nganSach <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ngân sách phải lớn hơn 0!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      widget.nganSachNhomChiTieu[_nhomDuocChon!] = nganSach;
    });
    await prefs.setString('${widget.currentUserPhone}_ngan_sach_nhom_chi_tieu', jsonEncode(widget.nganSachNhomChiTieu));
    widget.onSave(widget.nganSachNhomChiTieu);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu ngân sách thành công!'),
        backgroundColor: Color(0xFF34C759),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Thanh tiêu đề
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: const Color(0xFF6366F1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Quản lý ngân sách',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Phần nội dung chính
                    Container(
                      padding: const EdgeInsets.all(16),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thiết lập ngân sách',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Dropdown chọn nhóm
                          DropdownButtonFormField<String>(
                            value: _nhomDuocChon,
                            decoration: InputDecoration(
                              labelText: 'Chọn nhóm chi tiêu',
                              labelStyle: const TextStyle(
                                fontFamily: 'Roboto',
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF6366F1)),
                              ),
                            ),
                            items: widget.danhSachNhomChiTieu.map((nhom) => DropdownMenuItem(
                              value: nhom,
                              child: Text(
                                nhom,
                                style: const TextStyle(fontFamily: 'Roboto', fontSize: 14),
                              ),
                            )).toList(),
                            onChanged: (value) {
                              setState(() {
                                _nhomDuocChon = value;
                                _boDieuKhienNganSach.text = (widget.nganSachNhomChiTieu[value] ?? 0.0).toStringAsFixed(0);
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          // Ô nhập ngân sách
                          TextField(
                            controller: _boDieuKhienNganSach,
                            decoration: InputDecoration(
                              labelText: 'Ngân sách (VNĐ)',
                              labelStyle: const TextStyle(
                                fontFamily: 'Roboto',
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              suffixText: 'VNĐ',
                              suffixStyle: const TextStyle(
                                fontFamily: 'Roboto',
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF6366F1)),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Nút lưu
                          Center(
                            child: GestureDetector(
                              onTap: _saveNganSach,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Lưu ngân sách',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    _boDieuKhienNganSach.dispose();
    super.dispose();
  }
}