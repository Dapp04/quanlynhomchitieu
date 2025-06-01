// ignore_for_file: deprecated_member_use, avoid_print, library_private_types_in_public_api, unused_local_variable, unused_element

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../models/giao_dich.dart';
import '../../widgets/tab_button.dart';
import '../../utils/helpers.dart';

class TrangChuTab extends StatefulWidget {
  final String ten;
  final double soDu;
  final String? duongDanHinhDaiDien;
  final List<GiaoDich> danhSachGiaoDich;
  final int tabHienTai;
  final double tongChiTieu;
  final double tongThuNhap;
  final Function(int) onTabChanged;
  final Function(double) onSoDuChanged;
  final Function(String?) onImageChange;

  const TrangChuTab({
    super.key,
    required this.ten,
    required this.soDu,
    required this.duongDanHinhDaiDien,
    required this.danhSachGiaoDich,
    required this.tabHienTai,
    required this.tongChiTieu,
    required this.tongThuNhap,
    required this.onTabChanged,
    required this.onSoDuChanged,
    required this.onImageChange,
  });

  @override
  _TrangChuTabState createState() => _TrangChuTabState();
}

class _NumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('.', '');
    final formattedText = text.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class _TrangChuTabState extends State<TrangChuTab> with SingleTickerProviderStateMixin {
  bool hienThiTatCa = false;
  final TextEditingController soDuController = TextEditingController();
  late SharedPreferences prefs;
  double _tongTienTietKiem = 0.0;

  List<Map<String, dynamic>> _themes = [];
  String _selectedTheme = 'Light Teal';
  bool _isLoading = true;
  String _currentUserPhone = '';

  List<Map<String, dynamic>> _danhSachKhoanSoDu = [];
  List<String> _danhSachNganHang = [
    'Vietcombank',
    'VietinBank',
    'BIDV',
    'Techcombank',
    'VPBank',
    'MBBank',
    'Agribank',
    'HDBank',
    'Sacombank',
    'ACB',
  ];
  String _loaiKhoan = 'Tiền mặt';
  final List<String> _loaiKhoanCoSan = ['Tiền mặt', 'Tài khoản ngân hàng', 'Khác'];
  String? _nganHangDuocChon;
  final TextEditingController _tenKhoanMoiController = TextEditingController();
  final TextEditingController _tenNganHangMoiController = TextEditingController();
  bool _hienThiNhapNganHangMoi = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserPhone();
  }

  Future<void> _loadCurrentUserPhone() async {
    try {
      prefs = await SharedPreferences.getInstance();
      setState(() {
        _currentUserPhone = prefs.getString('currentUserPhone') ?? '';
        String? storedImagePath = prefs.getString('${_currentUserPhone}_profileImage');
        if (storedImagePath != null && File(storedImagePath).existsSync()) {
          widget.onImageChange(storedImagePath);
        } else {
          widget.onImageChange(null);
        }
        _initializeSharedPreferences();
      });
    } catch (e) {
      print('Lỗi khi tải thông tin người dùng: $e');
      setState(() {
        _currentUserPhone = '';
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeSharedPreferences() async {
    try {
      double? savedSoDu = prefs.getDouble('${_currentUserPhone}_soDu');
      await _loadDanhSachKhoanSoDu();

      List<String>? savedNganHang = prefs.getStringList('${_currentUserPhone}_danhSachNganHang');
      if (savedNganHang != null) {
        _danhSachNganHang = savedNganHang;
      }

      setState(() {
        _tongTienTietKiem = prefs.getDouble('${_currentUserPhone}_tongTienTietKiem') ?? 0.0;
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
        _isLoading = false;
      });
    } catch (e) {
      print('Lỗi khi tải dữ liệu trang chủ: $e');
      setState(() {
        _danhSachKhoanSoDu = [];
        _danhSachNganHang = [
          'Vietcombank',
          'VietinBank',
          'BIDV',
          'Techcombank',
          'VPBank',
          'MBBank',
          'Agribank',
          'HDBank',
          'Sacombank',
          'ACB',
        ];
        _tongTienTietKiem = 0.0;
        _themes = [
          {
            'name': 'Light Teal',
            'gradientColors': [const Color(0xFF40C4FF), const Color(0xFF81D4FA)],
            'primaryColor': const Color(0xFF40C4FF)
          },
        ];
        _selectedTheme = 'Light Teal';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDanhSachKhoanSoDu() async {
    List<String>? savedKhoanSoDu = prefs.getStringList('${_currentUserPhone}_danhSachKhoanSoDu');
    if (savedKhoanSoDu != null) {
      _danhSachKhoanSoDu = savedKhoanSoDu.map((item) {
        final parts = item.split('|');
        final tenKhoan = parts[1];
        double soDu = prefs.getDouble('${_currentUserPhone}_so_du_$tenKhoan') ?? double.tryParse(parts[2]) ?? 0.0;
        return {
          'loai': parts[0],
          'ten': tenKhoan,
          'soTien': soDu,
          'nganHang': parts.length > 3 ? parts[3] : null,
        };
      }).toList();
    } else {
      _danhSachKhoanSoDu = [];
    }
  }

  Future<void> _saveSoDu(double soDu, String nguonKhoan) async {
    await prefs.setDouble('${_currentUserPhone}_so_du_$nguonKhoan', soDu);
  }

  Future<void> _saveDanhSachKhoanSoDu() async {
    List<String> danhSachLuu = _danhSachKhoanSoDu.map((khoan) {
      return '${khoan['loai']}|${khoan['ten']}|${khoan['soTien']}${khoan['nganHang'] != null ? '|${khoan['nganHang']}' : ''}';
    }).toList();
    await prefs.setStringList('${_currentUserPhone}_danhSachKhoanSoDu', danhSachLuu);
  }

  Future<void> _saveDanhSachNganHang() async {
    await prefs.setStringList('${_currentUserPhone}_danhSachNganHang', _danhSachNganHang);
  }

  Future<void> _capNhatSoDuTuGiaoDich(Map<String, dynamic> giaoDichData) async {
    if (_danhSachKhoanSoDu.isEmpty) {
      return; // Không cập nhật số dư nếu danh sách khoản số dư rỗng
    }

    final soTien = giaoDichData['soTien'] as double;
    final loaiGiaoDich = giaoDichData['loai'] as String;

    final khoanIndex = 0;
    String tenKhoan = _danhSachKhoanSoDu[khoanIndex]['ten'];
    double soDuHienTai = _danhSachKhoanSoDu[khoanIndex]['soTien'];
    if (loaiGiaoDich == 'Chi tiêu') {
      soDuHienTai -= soTien;
    } else {
      soDuHienTai += soTien;
    }
    if (soDuHienTai < 0) soDuHienTai = 0;
    _danhSachKhoanSoDu[khoanIndex]['soTien'] = soDuHienTai;
    await _saveSoDu(soDuHienTai, tenKhoan);
    await _saveDanhSachKhoanSoDu();
    double tongSoDu = _danhSachKhoanSoDu.fold(0.0, (sum, khoan) => sum + khoan['soTien']) - _tongTienTietKiem;
    widget.onSoDuChanged(tongSoDu);
    setState(() {});
  }

  void _showSoDuDialog() {
    soDuController.text = '';
    _loaiKhoan = 'Tiền mặt';
    _nganHangDuocChon = null;
    _tenKhoanMoiController.text = '';
    _tenNganHangMoiController.text = '';
    _hienThiNhapNganHangMoi = false;

    final currentTheme = _themes.isNotEmpty
        ? _themes.firstWhere(
            (t) => t['name'] == _selectedTheme,
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Thêm khoản số dư',
          style: TextStyle(
            color: currentTheme['primaryColor'],
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _loaiKhoan,
                    decoration: InputDecoration(
                      labelText: 'Loại khoản',
                      labelStyle: TextStyle(color: Colors.grey.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: currentTheme['primaryColor']),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: _loaiKhoanCoSan.map((String loai) {
                      return DropdownMenuItem<String>(
                        value: loai,
                        child: Text(loai, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        _loaiKhoan = value!;
                        _nganHangDuocChon = null;
                        _hienThiNhapNganHangMoi = false;
                        _tenNganHangMoiController.text = '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_loaiKhoan == 'Tài khoản ngân hàng')
                    Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _nganHangDuocChon,
                          decoration: InputDecoration(
                            labelText: 'Chọn ngân hàng',
                            labelStyle: TextStyle(color: Colors.grey.shade600),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: currentTheme['primaryColor']),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Chọn ngân hàng', style: TextStyle(fontSize: 14)),
                            ),
                            ..._danhSachNganHang.map((String nganHang) {
                              return DropdownMenuItem<String>(
                                value: nganHang,
                                child: Text(nganHang, style: const TextStyle(fontSize: 14)),
                              );
                            }),
                            const DropdownMenuItem<String>(
                              value: 'them_ngan_hang_moi',
                              child: Text('Thêm ngân hàng mới', style: TextStyle(fontSize: 14)),
                            ),
                          ],
                          onChanged: (value) {
                            setStateDialog(() {
                              _nganHangDuocChon = value;
                              _hienThiNhapNganHangMoi = value == 'them_ngan_hang_moi';
                              if (!_hienThiNhapNganHangMoi) {
                                _tenNganHangMoiController.text = '';
                              }
                            });
                          },
                          validator: (value) {
                            if (_loaiKhoan == 'Tài khoản ngân hàng' && value == null) {
                              return 'Vui lòng chọn ngân hàng';
                            }
                            return null;
                          },
                        ),
                        if (_hienThiNhapNganHangMoi)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextField(
                              controller: _tenNganHangMoiController,
                              decoration: InputDecoration(
                                labelText: 'Tên ngân hàng mới',
                                labelStyle: TextStyle(color: Colors.grey.shade600),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: currentTheme['primaryColor']),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                          ),
                      ],
                    ),
                  if (_loaiKhoan == 'Khác')
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextField(
                        controller: _tenKhoanMoiController,
                        decoration: InputDecoration(
                          labelText: 'Tên khoản mới',
                          labelStyle: TextStyle(color: Colors.grey.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: currentTheme['primaryColor']),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: soDuController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _NumberFormatter(),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Số tiền (VNĐ)',
                      labelStyle: TextStyle(color: Colors.grey.shade600),
                      prefixIcon: Icon(
                        Icons.account_balance_wallet,
                        color: currentTheme['primaryColor'],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: currentTheme['primaryColor']),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              String rawInput = soDuController.text.replaceAll('.', '');
              double newSoDu = double.tryParse(rawInput) ?? 0.0;
              if (newSoDu < 0) newSoDu = 0;

              String tenKhoan;
              if (_loaiKhoan == 'Tài khoản ngân hàng') {
                if (_nganHangDuocChon == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng chọn ngân hàng')),
                  );
                  return;
                }
                if (_nganHangDuocChon == 'them_ngan_hang_moi') {
                  if (_tenNganHangMoiController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng nhập tên ngân hàng mới')),
                    );
                    return;
                  }
                  String tenNganHangMoi = _tenNganHangMoiController.text.trim();
                  if (!_danhSachNganHang.contains(tenNganHangMoi)) {
                    _danhSachNganHang.add(tenNganHangMoi);
                    _saveDanhSachNganHang();
                  }
                  tenKhoan = tenNganHangMoi;
                  _nganHangDuocChon = tenNganHangMoi;
                } else {
                  tenKhoan = _nganHangDuocChon!;
                }
              } else if (_loaiKhoan == 'Khác') {
                if (_tenKhoanMoiController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập tên khoản mới')),
                  );
                  return;
                }
                tenKhoan = _tenKhoanMoiController.text.trim();
                if (!_loaiKhoanCoSan.contains(tenKhoan)) {
                  _loaiKhoanCoSan.add(tenKhoan);
                }
              } else {
                tenKhoan = _loaiKhoan;
              }

              final existingKhoanIndex = _danhSachKhoanSoDu.indexWhere((khoan) => khoan['ten'] == tenKhoan);
              if (existingKhoanIndex != -1) {
                setState(() {
                  double currentSoDu = _danhSachKhoanSoDu[existingKhoanIndex]['soTien'];
                  _danhSachKhoanSoDu[existingKhoanIndex]['soTien'] = currentSoDu + newSoDu;
                  _saveSoDu(_danhSachKhoanSoDu[existingKhoanIndex]['soTien'], tenKhoan);
                  _saveDanhSachKhoanSoDu();
                });
              } else {
                setState(() {
                  _danhSachKhoanSoDu.add({
                    'loai': _loaiKhoan,
                    'ten': tenKhoan,
                    'soTien': newSoDu,
                    'nganHang': _loaiKhoan == 'Tài khoản ngân hàng' ? _nganHangDuocChon : null,
                  });
                  _saveSoDu(newSoDu, tenKhoan);
                  _saveDanhSachKhoanSoDu();
                });
              }

              double tongSoDu = _danhSachKhoanSoDu.fold(0.0, (sum, khoan) => sum + khoan['soTien']) - _tongTienTietKiem;
              widget.onSoDuChanged(tongSoDu);

              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [currentTheme['primaryColor'], currentTheme['primaryColor'].withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Lưu',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<GiaoDich> locGiaoDichTheoThoiGian(List<GiaoDich> giaoDichList, int tabHienTai) {
    DateTime now = DateTime.now();
    List<GiaoDich> danhSachLoc = [];

    for (var giaoDich in giaoDichList) {
      DateTime ngayGiaoDich = giaoDich.ngayGio;

      switch (tabHienTai) {
        case 0:
          if (ngayGiaoDich.day == now.day &&
              ngayGiaoDich.month == now.month &&
              ngayGiaoDich.year == now.year) {
            danhSachLoc.add(giaoDich);
          }
          break;

        case 1:
          DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
          if (ngayGiaoDich.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              ngayGiaoDich.isBefore(endOfWeek.add(const Duration(days: 1)))) {
            danhSachLoc.add(giaoDich);
          }
          break;

        case 2:
          if (ngayGiaoDich.month == now.month && ngayGiaoDich.year == now.year) {
            danhSachLoc.add(giaoDich);
          }
          break;

        case 3:
          if (ngayGiaoDich.year == now.year) {
            danhSachLoc.add(giaoDich);
          }
          break;
      }
    }

    danhSachLoc.sort((a, b) => b.ngayGio.compareTo(a.ngayGio));

    return danhSachLoc;
  }

  @override
  void didUpdateWidget(TrangChuTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadTongTienTietKiem();
    _loadDanhSachKhoanSoDu();
  }

  Future<void> _loadTongTienTietKiem() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _tongTienTietKiem = prefs.getDouble('${_currentUserPhone}_tongTienTietKiem') ?? 0.0;
      });
    } catch (e) {
      print('Lỗi khi tải tổng tiền tiết kiệm: $e');
      setState(() {
        _tongTienTietKiem = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final currentTheme = _themes.isNotEmpty
        ? _themes.firstWhere(
            (t) => t['name'] == _selectedTheme,
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

    final danhSachLoc = locGiaoDichTheoThoiGian(widget.danhSachGiaoDich, widget.tabHienTai);
    final danhSachHienThi = hienThiTatCa ? danhSachLoc : danhSachLoc.take(5).toList();
    double soDuHieuChinh = _danhSachKhoanSoDu.fold(0.0, (sum, khoan) => sum + khoan['soTien']) - _tongTienTietKiem;
    String chuCaiDau = widget.ten.isNotEmpty ? widget.ten[0].toUpperCase() : 'U';

    return SafeArea(
      child: Container(
        color: Colors.grey.shade100,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: currentTheme['gradientColors'],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      layNgayHienTai(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          widget.ten,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.grey.shade300,
                            child: widget.duongDanHinhDaiDien != null &&
                                    File(widget.duongDanHinhDaiDien!).existsSync()
                                ? ClipOval(
                                    child: Image.file(
                                      File(widget.duongDanHinhDaiDien!),
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              currentTheme['primaryColor'],
                                              currentTheme['primaryColor'].withOpacity(0.8)
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            chuCaiDau,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          currentTheme['primaryColor'],
                                          currentTheme['primaryColor'].withOpacity(0.8)
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        chuCaiDau,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Balance Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: currentTheme['primaryColor'].withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Số dư tài khoản',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${soDuHieuChinh.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ',
                            style: TextStyle(
                              color: currentTheme['primaryColor'],
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_danhSachKhoanSoDu.isNotEmpty)
                            Container(
                              constraints: const BoxConstraints(maxHeight: 80),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: _danhSachKhoanSoDu.map((khoan) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            khoan['ten'],
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '${khoan['soTien'].toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ',
                                            style: TextStyle(
                                              color: currentTheme['primaryColor'],
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _showSoDuDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shadowColor: Colors.transparent,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    currentTheme['primaryColor'],
                                    currentTheme['primaryColor'].withOpacity(0.8)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: const Text(
                                'Thêm khoản số dư',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Summary Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: _buildSummaryCard(
                          title: 'Thu nhập',
                          value: widget.tongThuNhap / 1000,
                          color: const Color(0xFF4CAF50),
                          icon: Icons.arrow_upward,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: _buildSummaryCard(
                          title: 'Chi tiêu',
                          value: widget.tongChiTieu / 1000,
                          color: const Color(0xFFE57373),
                          icon: Icons.arrow_downward,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TabButton(
                          title: 'Hôm nay',
                          index: 0,
                          isSelected: widget.tabHienTai == 0,
                          onTap: widget.onTabChanged,
                        ),
                        TabButton(
                          title: 'Tuần',
                          index: 1,
                          isSelected: widget.tabHienTai == 1,
                          onTap: widget.onTabChanged,
                        ),
                        TabButton(
                          title: 'Tháng',
                          index: 2,
                          isSelected: widget.tabHienTai == 2,
                          onTap: widget.onTabChanged,
                        ),
                        TabButton(
                          title: 'Năm',
                          index: 3,
                          isSelected: widget.tabHienTai == 3,
                          onTap: widget.onTabChanged,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Transaction Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              hienThiTatCa = false;
                            });
                          },
                          child: Text(
                            'Giao dịch gần đây',
                            style: TextStyle(
                              color: hienThiTatCa ? Colors.grey.shade500 : Colors.black,
                              fontSize: 16,
                              fontWeight: hienThiTatCa ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              hienThiTatCa = true;
                            });
                          },
                          child: Text(
                            'Hiển thị tất cả',
                            style: TextStyle(
                              color: hienThiTatCa ? Colors.black : Colors.grey.shade500,
                              fontSize: 16,
                              fontWeight: hienThiTatCa ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Transaction List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: danhSachHienThi.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.hourglass_empty,
                                size: 60,
                                color: currentTheme['primaryColor'].withOpacity(0.6),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Chưa có giao dịch nào',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Thêm giao dịch để bắt đầu!',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: danhSachHienThi.asMap().entries.map((entry) {
                            final index = entry.key;
                            final giaoDich = entry.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: index % 2 == 0 ? Colors.white : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: giaoDich.loai == 'Thu nhập'
                                            ? const Color(0xFF4CAF50)
                                            : const Color(0xFFE57373),
                                        child: Icon(
                                          giaoDich.loai == 'Thu nhập'
                                              ? Icons.arrow_upward
                                              : Icons.arrow_downward,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              giaoDich.moTa,
                                              style: TextStyle(
                                                color: Colors.grey.shade800,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              DateFormat('dd/MM/yyyy').format(giaoDich.ngayGio),
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 12,
                                              ),
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
                                              color: giaoDich.loai == 'Thu nhập'
                                                  ? const Color(0xFF4CAF50)
                                                  : const Color(0xFFE57373),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            giaoDich.loai,
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${value.toStringAsFixed(0)}k',
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<Map<String, dynamic>>('_themes', _themes));
  }
}