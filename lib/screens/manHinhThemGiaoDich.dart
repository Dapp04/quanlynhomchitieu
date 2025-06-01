// ignore_for_file: file_names, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

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

  // Định dạng số tiền với dấu chấm phân cách hàng nghìn
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

    // Listener để định dạng số tiền khi người dùng nhập
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

  void _showThemNhomDialog() {
    _boDieuKhienNhomMoi.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Thêm nhóm mới',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF40C4FF),
          ),
        ),
        content: TextField(
          controller: _boDieuKhienNhomMoi,
          decoration: InputDecoration(
            labelText: 'Tên nhóm',
            labelStyle: const TextStyle(color: Colors.black54),
            prefixIcon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF40C4FF),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF40C4FF), width: 2),
            ),
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
                    backgroundColor: Color(0xFFEF5350),
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
                  backgroundColor: Color(0xFF4CAF50),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF40C4FF), Color(0xFF81D4FA)],
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
                'Thêm',
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

  void _showThemNguonKhoanDialog() {
    _boDieuKhienNguonKhoanMoi.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Thêm nguồn khoản mới',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF40C4FF),
          ),
        ),
        content: TextField(
          controller: _boDieuKhienNguonKhoanMoi,
          decoration: InputDecoration(
            labelText: 'Tên nguồn khoản',
            labelStyle: const TextStyle(color: Colors.black54),
            prefixIcon: const Icon(
              Icons.account_balance_wallet,
              color: Color(0xFF40C4FF),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF40C4FF), width: 2),
            ),
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
                    backgroundColor: Color(0xFFEF5350),
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
                  backgroundColor: Color(0xFF4CAF50),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF40C4FF), Color(0xFF81D4FA)],
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
                'Thêm',
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
              primary: Color(0xFF40C4FF),
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
      appBar: AppBar(
        title: const Text(
          'Thêm giao dịch',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF40C4FF), Color(0xFF81D4FA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _boDieuKhienSoTien,
                        decoration: InputDecoration(
                          labelText: 'Số tiền',
                          labelStyle: const TextStyle(color: Colors.black54),
                          prefixIcon: const Icon(
                            Icons.attach_money,
                            color: Color(0xFF40C4FF),
                          ),
                          suffixText: 'VND',
                          suffixStyle: const TextStyle(color: Colors.black54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF40C4FF)),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _boDieuKhienMoTa,
                        decoration: InputDecoration(
                          labelText: 'Mô tả',
                          labelStyle: const TextStyle(color: Colors.black54),
                          prefixIcon: const Icon(
                            Icons.description,
                            color: Color(0xFF40C4FF),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF40C4FF)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _loaiGiaoDich == 'Thu nhập'
                                      ? [const Color(0xFF66BB6A), const Color(0xFF4CAF50)]
                                      : [Colors.grey.shade200, Colors.grey.shade300],
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
                              child: Text(
                                'Thu nhập',
                                style: TextStyle(
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
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _loaiGiaoDich == 'Chi tiêu'
                                      ? [const Color(0xFFEF5350), const Color(0xFFE53935)]
                                      : [Colors.grey.shade200, Colors.grey.shade300],
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
                              child: Text(
                                'Chi tiêu',
                                style: TextStyle(
                                  color: _loaiGiaoDich == 'Chi tiêu' ? Colors.white : Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _nhomGiaoDich,
                        decoration: InputDecoration(
                          labelText: 'Chọn nhóm',
                          labelStyle: const TextStyle(color: Colors.black54),
                          prefixIcon: const Icon(
                            Icons.category,
                            color: Color(0xFF40C4FF),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF40C4FF)),
                          ),
                        ),
                        items: [
                          ...danhSachNhomHienTai.map((nhom) => DropdownMenuItem(
                                value: nhom,
                                child: Text(nhom),
                              )),
                          const DropdownMenuItem(
                            value: 'ThemNhomMoi',
                            child: Text('Thêm nhóm mới', style: TextStyle(color: Color(0xFF40C4FF))),
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
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _nguonKhoanDuocChon,
                        decoration: InputDecoration(
                          labelText: 'Nguồn khoản',
                          labelStyle: const TextStyle(color: Colors.black54),
                          prefixIcon: const Icon(
                            Icons.account_balance_wallet,
                            color: Color(0xFF40C4FF),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF40C4FF)),
                          ),
                        ),
                        items: [
                          if (danhSachNguonKhoan.isNotEmpty)
                            ...danhSachNguonKhoan.map((nguon) => DropdownMenuItem(
                                  value: nguon,
                                  child: Text(nguon),
                                )),
                          const DropdownMenuItem(
                            value: 'ThemNguonKhoanMoi',
                            child: Text('Thêm nguồn khoản mới', style: TextStyle(color: Color(0xFF40C4FF))),
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
                          if (value == null || value == 'null' || value == 'ThemNguonKhoanMoi') {
                            return 'Vui lòng chọn nguồn khoản';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _boDieuKhienNgay,
                        decoration: InputDecoration(
                          labelText: 'Chọn ngày',
                          labelStyle: const TextStyle(color: Colors.black54),
                          prefixIcon: const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF40C4FF),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF40C4FF)),
                          ),
                        ),
                        readOnly: true,
                        onTap: _chonNgay,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
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
                        'Hủy',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
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
                      if (_nguonKhoanDuocChon == null || _nguonKhoanDuocChon == 'null') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng chọn nguồn khoản')),
                        );
                        return;
                      }

                      if (_loaiGiaoDich == 'Chi tiêu') {
                        try {
                          await _capNhatSoDu(soTien, _nguonKhoanDuocChon!);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Số dư không đủ'),
                              backgroundColor: Color(0xFFEF5350),
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

                      // Trả về dữ liệu giao dịch và số dư mới theo nguồn khoản
                      final double soDuMoi = await _laySoDuHienTai(_nguonKhoanDuocChon!);
                      Navigator.pop(context, {
                        'loai': _loaiGiaoDich,
                        'soTien': soTien,
                        'moTa': _boDieuKhienMoTa.text,
                        'ngay': _ngayDuocChon, // Trả về DateTime thay vì chuỗi
                        'nhom': _nhomGiaoDich,
                        'nguonKhoan': _nguonKhoanDuocChon,
                        'soDu': soDuMoi,
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF40C4FF), Color(0xFF81D4FA)],
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
                        'Thêm',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}