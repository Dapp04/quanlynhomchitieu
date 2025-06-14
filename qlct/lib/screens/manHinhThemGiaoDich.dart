// ignore_for_file: file_names, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import 'dart:convert';
import 'manhinhThemNganSach.dart';

class ManHinhThemGiaoDich extends StatefulWidget {
  const ManHinhThemGiaoDich({super.key});

  @override
  State<ManHinhThemGiaoDich> createState() => _ManHinhThemGiaoDichState();
}

class _ManHinhThemGiaoDichState extends State<ManHinhThemGiaoDich> {
  final TextEditingController _boDieuKhienSoTien = TextEditingController();
  final TextEditingController _boDieuKhienMoTa = TextEditingController();
  final TextEditingController _boDieuKhienNgay = TextEditingController();
  final TextEditingController _boDieuKhienNhomMoi = TextEditingController();
  final TextEditingController _boDieuKhienNguonKhoanMoi = TextEditingController();
  String _loaiGiaoDich = 'Thu nhập';
  String _nhomGiaoDich = 'Khác';
  DateTime _ngayDuocChon = DateTime.now();
  List<String> _danhSachNhomChiTieu = [];
  List<String> _danhSachNhomThuNhap = [];
  bool _isLoading = true;
  String _currentUserPhone = '';
  List<Map<String, dynamic>> _danhSachKhoanSoDu = [];
  String? _nguonKhoanDuocChon;
  Map<String, double> _nganSachNhomChiTieu = {};
  List<Map<String, dynamic>> _danhSachGiaoDich = [];

  String _formatNumber(String text) {
    if (text.isEmpty) return '';
    final number = double.tryParse(text.replaceAll('.', '')) ?? 0;
    return number.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _boDieuKhienNgay.text =
        '${_ngayDuocChon.day.toString().padLeft(2, '0')}/${_ngayDuocChon.month.toString().padLeft(2, '0')}/${_ngayDuocChon.year}';

    _boDieuKhienSoTien.addListener(() {
      final text = _boDieuKhienSoTien.text.replaceAll('.', '');
      if (text.isEmpty) return;
      final formatted = _formatNumber(text);
      if (_boDieuKhienSoTien.text != formatted) {
        _boDieuKhienSoTien.value = _boDieuKhienSoTien.value.copyWith(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    });
  }

  Future<void> _loadInitialData() async {
    await _loadCurrentUserPhone();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadCurrentUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserPhone = prefs.getString('currentUserPhone') ?? '';
      _loadDanhSachNhom();
      _loadDanhSachKhoanSoDu();
      _loadNganSachNhomChiTieu();
      _loadDanhSachGiaoDich();
    });
  }

  Future<void> _loadDanhSachNhom() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNhomChiTieu = prefs.getStringList('${_currentUserPhone}_danh_sach_nhom_chi_tieu');
    final savedNhomThuNhap = prefs.getStringList('${_currentUserPhone}_danh_sach_nhom_thu_nhap');
    setState(() {
      _danhSachNhomChiTieu = savedNhomChiTieu ??
          [
            'Đồ ăn',
            'Mua sắm',
            'Giải trí',
            'Du lịch',
            'Học tập',
            'Khác',
          ];
      _danhSachNhomThuNhap = savedNhomThuNhap ??
          [
            'Lương',
            'Trợ cấp',
            'Thưởng',
            'Khác',
          ];
      _nhomGiaoDich = _loaiGiaoDich == 'Chi tiêu'
          ? (_danhSachNhomChiTieu.contains('Khác') ? 'Khác' : _danhSachNhomChiTieu.first)
          : (_danhSachNhomThuNhap.contains('Khác') ? 'Khác' : _danhSachNhomThuNhap.first);
    });
  }

  Future<void> _loadDanhSachKhoanSoDu() async {
    final prefs = await SharedPreferences.getInstance();
    final savedKhoanSoDu = prefs.getStringList('${_currentUserPhone}_danhSachKhoanSoDu');
    if (savedKhoanSoDu != null) {
      setState(() {
        _danhSachKhoanSoDu = savedKhoanSoDu.map((item) {
          final parts = item.split('|');
          return {
            'loai': parts[0],
            'ten': parts[1],
            'soTien': double.parse(parts[2]),
            'nganHang': parts.length > 3 ? parts[3] : null,
          };
        }).toList();
        final List<String> danhSachNguonKhoan = _danhSachKhoanSoDu.map((khoan) => khoan['ten'] as String).toSet().toList();
        _nguonKhoanDuocChon = danhSachNguonKhoan.isNotEmpty ? danhSachNguonKhoan.first : null;
      });
    }
  }

  Future<void> _loadNganSachNhomChiTieu() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNganSach = prefs.getString('${_currentUserPhone}_ngan_sach_nhom_chi_tieu');
    if (savedNganSach != null) {
      try {
        final decoded = jsonDecode(savedNganSach);
        if (decoded is Map) {
          setState(() {
            _nganSachNhomChiTieu = decoded.map((key, value) => MapEntry(key as String, (value as num).toDouble()));
          });
        }
      } catch (e) {
        print('Lỗi khi load ngân sách: $e');
        setState(() {
          _nganSachNhomChiTieu = {};
        });
      }
    }
  }

  Future<void> _loadDanhSachGiaoDich() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGiaoDich = prefs.getString('${_currentUserPhone}_danh_sach_giao_dich');
    if (savedGiaoDich != null) {
      try {
        final List<dynamic> giaoDichList = jsonDecode(savedGiaoDich);
        setState(() {
          _danhSachGiaoDich = giaoDichList.map((item) {
            return {
              'loai': item['loai'] as String? ?? 'Chi tiêu',
              'soTien': double.parse((item['soTien']?.toString() ?? '0')),
              'moTa': item['moTa'] as String? ?? '',
              'ngay': DateTime.parse(item['ngay'] as String? ?? DateTime.now().toIso8601String()),
              'nhom': item['nhom'] as String? ?? 'Khác',
              'nguonKhoan': item['nguonKhoan'] as String? ?? '',
              'soDu': double.parse((item['soDu']?.toString() ?? '0')),
            };
          }).toList();
        });
      } catch (e) {
        print('Lỗi khi load danh sách giao dịch: $e');
        setState(() {
          _danhSachGiaoDich = [];
        });
      }
    }
  }

  Future<void> _saveNganSachNhomChiTieu() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_currentUserPhone}_ngan_sach_nhom_chi_tieu', jsonEncode(_nganSachNhomChiTieu));
  }

  Future<void> _saveDanhSachNhom() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('${_currentUserPhone}_danh_sach_nhom_chi_tieu', _danhSachNhomChiTieu);
    await prefs.setStringList('${_currentUserPhone}_danh_sach_nhom_thu_nhap', _danhSachNhomThuNhap);
  }

  Future<void> _saveDanhSachKhoanSoDu() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedKhoanSoDu = _danhSachKhoanSoDu.map((khoan) {
      return '${khoan['loai']}|${khoan['ten']}|${khoan['soTien']}${khoan['nganHang'] != null ? '|${khoan['nganHang']}' : ''}';
    }).toList();
    await prefs.setStringList('${_currentUserPhone}_danhSachKhoanSoDu', savedKhoanSoDu);
  }

  Future<double> _laySoDuHienTai(String nguonKhoan) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('${_currentUserPhone}_so_du_$nguonKhoan') ?? 0.0;
  }

  Future<void> _capNhatSoDu(double soTien, String nguonKhoan) async {
    final prefs = await SharedPreferences.getInstance();
    double soDuHienTai = await _laySoDuHienTai(nguonKhoan);
    if (_loaiGiaoDich == 'Chi tiêu') {
      if (soTien > soDuHienTai) {
        throw Exception('Số dư không đủ');
      }
      soDuHienTai -= soTien;
    } else {
      soDuHienTai += soTien;
    }
    await prefs.setDouble('${_currentUserPhone}_so_du_$nguonKhoan', soDuHienTai);
  }

  double _tinhTongChiTieuTrongThang(String nhom) {
    final thangHienTai = DateTime(_ngayDuocChon.year, _ngayDuocChon.month);
    return _danhSachGiaoDich
        .where((gd) =>
            gd['loai'] == 'Chi tiêu' &&
            gd['nhom'] == nhom &&
            DateTime(gd['ngay'].year, gd['ngay'].month) == thangHienTai)
        .fold(0.0, (sum, gd) => sum + (gd['soTien'] as double));
  }

  void _showThemNhomDialog() {
    _boDieuKhienNhomMoi.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Thêm nhóm mới',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Color(0xFF6366F1),
          ),
        ),
        content: TextField(
          controller: _boDieuKhienNhomMoi,
          decoration: InputDecoration(
            labelText: 'Tên nhóm',
            labelStyle: TextStyle(
              fontFamily: 'Roboto',
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          GestureDetector(
            onTap: () {
              final tenNhomMoi = _boDieuKhienNhomMoi.text.trim();
              if (tenNhomMoi.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập tên nhóm!'),
                    backgroundColor: Color(0xFFFF2D55),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              setState(() {
                if (_loaiGiaoDich == 'Chi tiêu') {
                  if (!_danhSachNhomChiTieu.contains(tenNhomMoi)) {
                    _danhSachNhomChiTieu.add(tenNhomMoi);
                  }
                  _nhomGiaoDich = tenNhomMoi;
                } else {
                  if (!_danhSachNhomThuNhap.contains(tenNhomMoi)) {
                    _danhSachNhomThuNhap.add(tenNhomMoi);
                  }
                  _nhomGiaoDich = tenNhomMoi;
                }
              });

              _saveDanhSachNhom();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã thêm nhóm mới!'),
                  backgroundColor: Color(0xFF34C759),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Thêm',
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

  void _showThemNguonKhoanDialog() {
    _boDieuKhienNguonKhoanMoi.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Thêm nguồn khoản mới',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Color(0xFF6366F1),
          ),
        ),
        content: TextField(
          controller: _boDieuKhienNguonKhoanMoi,
          decoration: InputDecoration(
            labelText: 'Tên nguồn khoản',
            labelStyle: TextStyle(
              fontFamily: 'Roboto',
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          GestureDetector(
            onTap: () {
              final tenNguonKhoanMoi = _boDieuKhienNguonKhoanMoi.text.trim();
              if (tenNguonKhoanMoi.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập tên nguồn khoản!'),
                    backgroundColor: Color(0xFFFF2D55),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              setState(() {
                _danhSachKhoanSoDu.add({
                  'loai': 'Tiền mặt',
                  'ten': tenNguonKhoanMoi,
                  'soTien': 0.0,
                  'nganHang': null,
                });
                _nguonKhoanDuocChon = tenNguonKhoanMoi;
              });

              _saveDanhSachKhoanSoDu();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã thêm nguồn khoản mới!'),
                  backgroundColor: Color(0xFF34C759),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Thêm',
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

  void _showCanhBaoVuotNganSach(String nhom, double tongChiTieuMoi, double soTien, Function onContinue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Cảnh báo vượt ngân sách',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF2D55),
          ),
        ),
        content: Text(
          'Nhóm "$nhom" đã vượt ngân sách! Tổng chi tiêu: ${tongChiTieuMoi.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ / Ngân sách: ${_nganSachNhomChiTieu[nhom]!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ. Bạn có muốn tiếp tục?',
          style: const TextStyle(fontFamily: 'Roboto', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không', style: TextStyle(color: Colors.grey)),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              onContinue();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
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

  Future<void> _chonNgay() async {
    final DateTime? ngayChon = await showDatePicker(
      context: context,
      initialDate: _ngayDuocChon,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (ngayChon != null && ngayChon != _ngayDuocChon) {
      setState(() {
        _ngayDuocChon = ngayChon;
        _boDieuKhienNgay.text =
            '${ngayChon.day.toString().padLeft(2, '0')}/${ngayChon.month.toString().padLeft(2, '0')}/${ngayChon.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<String> danhSachNhomHienTai =
        _loaiGiaoDich == 'Chi tiêu' ? _danhSachNhomChiTieu : _danhSachNhomThuNhap;
    final List<String> danhSachNguonKhoan = _danhSachKhoanSoDu.map((khoan) => khoan['ten'] as String).toSet().toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              color: const Color(0xFF6366F1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Thêm Giao Dịch',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Nút Quản lý ngân sách được di chuyển xuống đây
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManHinhThemNganSach(
                              currentUserPhone: _currentUserPhone,
                              danhSachNhomChiTieu: _danhSachNhomChiTieu,
                              nganSachNhomChiTieu: _nganSachNhomChiTieu,
                              onSave: (updatedNganSach) {
                                setState(() {
                                  _nganSachNhomChiTieu = updatedNganSach;
                                });
                                _saveNganSachNhomChiTieu();
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Quản lý ngân sách',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Phần Thông tin giao dịch
                    Container(
                      padding: const EdgeInsets.all(12),
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
                            'Thông Tin Giao Dịch',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _boDieuKhienSoTien,
                            decoration: InputDecoration(
                              labelText: 'Số tiền (VNĐ)',
                              labelStyle: TextStyle(
                                fontFamily: 'Roboto',
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                              suffixText: 'VNĐ',
                              suffixStyle: TextStyle(
                                fontFamily: 'Roboto',
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
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
                          const SizedBox(height: 8),
                          TextField(
                            controller: _boDieuKhienMoTa,
                            decoration: InputDecoration(
                              labelText: 'Mô tả',
                              labelStyle: TextStyle(
                                fontFamily: 'Roboto',
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF6366F1)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _loaiGiaoDich = 'Thu nhập';
                                    _nhomGiaoDich = _danhSachNhomThuNhap.contains('Khác')
                                        ? 'Khác'
                                        : _danhSachNhomThuNhap.first;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _loaiGiaoDich == 'Thu nhập'
                                        ? const Color(0xFF34C759)
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Thu nhập',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      color: _loaiGiaoDich == 'Thu nhập' ? Colors.white : Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _loaiGiaoDich = 'Chi tiêu';
                                    _nhomGiaoDich = _danhSachNhomChiTieu.contains('Khác')
                                        ? 'Khác'
                                        : _danhSachNhomChiTieu.first;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _loaiGiaoDich == 'Chi tiêu'
                                        ? const Color(0xFFFF2D55)
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Chi tiêu',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      color: _loaiGiaoDich == 'Chi tiêu' ? Colors.white : Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _nhomGiaoDich,
                            decoration: InputDecoration(
                              labelText: 'Chọn nhóm',
                              labelStyle: TextStyle(
                                fontFamily: 'Roboto',
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF6366F1)),
                              ),
                            ),
                            items: [
                              ...danhSachNhomHienTai.map((nhom) => DropdownMenuItem(
                                    value: nhom,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(nhom, style: const TextStyle(fontFamily: 'Roboto', fontSize: 14)),
                                        if (_loaiGiaoDich == 'Chi tiêu' && _nganSachNhomChiTieu[nhom] != null)
                                          Text(
                                            'Ngân sách: ${_nganSachNhomChiTieu[nhom]!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ',
                                            style: const TextStyle(fontFamily: 'Roboto', fontSize: 12, color: Colors.grey),
                                          ),
                                      ],
                                    ),
                                  )),
                              const DropdownMenuItem(
                                value: 'ThemNhomMoi',
                                child: Text('Thêm nhóm mới', style: TextStyle(color: Color(0xFF6366F1), fontSize: 14)),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == 'ThemNhomMoi') {
                                _showThemNhomDialog();
                              } else {
                                setState(() {
                                  _nhomGiaoDich = value!;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _nguonKhoanDuocChon,
                            decoration: InputDecoration(
                              labelText: 'Nguồn khoản',
                              labelStyle: TextStyle(
                                fontFamily: 'Roboto',
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF6366F1)),
                              ),
                            ),
                            items: [
                              if (danhSachNguonKhoan.isNotEmpty)
                                ...danhSachNguonKhoan.map((nguon) => DropdownMenuItem(
                                      value: nguon,
                                      child: Text(nguon, style: const TextStyle(fontFamily: 'Roboto', fontSize: 14)),
                                    )),
                              const DropdownMenuItem(
                                value: 'ThemNguonKhoanMoi',
                                child: Text('Thêm nguồn khoản mới', style: TextStyle(color: Color(0xFF6366F1), fontSize: 14)),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == 'ThemNguonKhoanMoi') {
                                _showThemNguonKhoanDialog();
                              } else {
                                setState(() {
                                  _nguonKhoanDuocChon = value;
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null || value == 'ThemNguonKhoanMoi') {
                                return 'Vui lòng chọn nguồn khoản';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _boDieuKhienNgay,
                            decoration: InputDecoration(
                              labelText: 'Chọn ngày',
                              labelStyle: TextStyle(
                                fontFamily: 'Roboto',
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF6366F1)),
                              ),
                            ),
                            readOnly: true,
                            onTap: _chonNgay,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Center(
                                child: Text(
                                  'Hủy',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: GestureDetector(
                            onTap: () async {
                              final String rawText = _boDieuKhienSoTien.text.replaceAll('.', '');
                              final double soTien = double.tryParse(rawText) ?? 0.0;
                              if (soTien <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Số tiền phải lớn hơn 0')),
                                );
                                return;
                              }
                              if (_boDieuKhienMoTa.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Vui lòng nhập mô tả')),
                                );
                                return;
                              }
                              if (_nguonKhoanDuocChon == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Vui lòng chọn nguồn khoản')),
                                );
                                return;
                              }

                              if (_loaiGiaoDich == 'Chi tiêu') {
                                final double nganSach = _nganSachNhomChiTieu[_nhomGiaoDich] ?? 0.0;
                                if (nganSach > 0) {
                                  final double tongChiTieuHienTai = _tinhTongChiTieuTrongThang(_nhomGiaoDich);
                                  final double tongChiTieuMoi = tongChiTieuHienTai + soTien;
                                  if (tongChiTieuMoi > nganSach) {
                                    _showCanhBaoVuotNganSach(_nhomGiaoDich, tongChiTieuMoi, soTien, () async {
                                      try {
                                        await _capNhatSoDu(soTien, _nguonKhoanDuocChon!);
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Số dư không đủ'),
                                            backgroundColor: Color(0xFFFF2D55),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                        return;
                                      }
                                      final String formattedSoTien = _formatNumber(rawText);
                                      final String notificationBody = '- $formattedSoTien VNĐ (Chi tiêu)';
                                      await NotificationService.showNotification(
                                        id: 5,
                                        title: 'Giao dịch mới',
                                        body: notificationBody,
                                      );
                                      final double soDuMoi = await _laySoDuHienTai(_nguonKhoanDuocChon!);
                                      Navigator.pop(context, {
                                        'loai': _loaiGiaoDich,
                                        'soTien': soTien,
                                        'moTa': _boDieuKhienMoTa.text,
                                        'ngay': _ngayDuocChon,
                                        'nhom': _nhomGiaoDich,
                                        'nguonKhoan': _nguonKhoanDuocChon,
                                        'soDu': soDuMoi,
                                      });
                                      setState(() {
                                        _nganSachNhomChiTieu[_nhomGiaoDich] = 0.0;
                                      });
                                      _saveNganSachNhomChiTieu();
                                    });
                                    return;
                                  }
                                }

                                try {
                                  await _capNhatSoDu(soTien, _nguonKhoanDuocChon!);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Số dư không đủ'),
                                      backgroundColor: Color(0xFFFF2D55),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }
                              } else {
                                await _capNhatSoDu(soTien, _nguonKhoanDuocChon!);
                              }

                              final String formattedSoTien = _formatNumber(rawText);
                              final String notificationBody = _loaiGiaoDich == 'Thu nhập'
                                  ? '+ $formattedSoTien VNĐ (Thu nhập)'
                                  : '- $formattedSoTien VNĐ (Chi tiêu)';
                              await NotificationService.showNotification(
                                id: 5,
                                title: 'Giao dịch mới',
                                body: notificationBody,
                              );

                              final double soDuMoi = await _laySoDuHienTai(_nguonKhoanDuocChon!);
                              Navigator.pop(context, {
                                'loai': _loaiGiaoDich,
                                'soTien': soTien,
                                'moTa': _boDieuKhienMoTa.text,
                                'ngay': _ngayDuocChon,
                                'nhom': _nhomGiaoDich,
                                'nguonKhoan': _nguonKhoanDuocChon,
                                'soDu': soDuMoi,
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  'Thêm',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
    _boDieuKhienSoTien.dispose();
    _boDieuKhienMoTa.dispose();
    _boDieuKhienNgay.dispose();
    _boDieuKhienNhomMoi.dispose();
    _boDieuKhienNguonKhoanMoi.dispose();
    super.dispose();
  }
}