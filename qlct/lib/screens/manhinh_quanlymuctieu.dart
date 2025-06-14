// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../tabs/number_formatter.dart';
import 'package:flutter/services.dart';

class ManHinhQuanLyMucTieu extends StatefulWidget {
  final double mucTieu;
  final double tongTienTietKiem;
  final double soDu;
  final Function(double, DateTime)? onMucTieuUpdated;

  const ManHinhQuanLyMucTieu({
    super.key,
    required this.mucTieu,
    required this.tongTienTietKiem,
    required this.soDu,
    this.onMucTieuUpdated,
  });

  @override
  State<ManHinhQuanLyMucTieu> createState() => _ManHinhQuanLyMucTieuState();
}

class _ManHinhQuanLyMucTieuState extends State<ManHinhQuanLyMucTieu> {
  final TextEditingController _mucTieuController = TextEditingController();
  final TextEditingController _moTaMucTieuController = TextEditingController();
  final TextEditingController _tienTietKiemController = TextEditingController();
  final TextEditingController _tienRutController = TextEditingController();
  final TextEditingController _ngayBatDauController = TextEditingController();
  final TextEditingController _ngayKetThucController = TextEditingController();
  double _mucTieu = 0.0;
  double _tongTienTietKiem = 0.0;
  DateTime _ngayBatDau = DateTime.now();
  DateTime _ngayKetThuc = DateTime.now();
  String _khoangThoiGian = 'Tùy chỉnh';
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
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _mucTieu = widget.mucTieu;
      _tongTienTietKiem = widget.tongTienTietKiem;
      _mucTieuController.text = _mucTieu > 0
          ? _mucTieu.toStringAsFixed(0).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')
          : '';
      _moTaMucTieuController.text = prefs.getString('${_currentUserPhone}_moTaMucTieu') ?? '';

      String? savedNgayBatDau = prefs.getString('${_currentUserPhone}_ngayBatDauMucTieu');
      String? savedNgayKetThuc = prefs.getString('${_currentUserPhone}_ngayKetThucMucTieu');
      _khoangThoiGian = prefs.getString('${_currentUserPhone}_khoangThoiGianMucTieu') ?? 'Tùy chỉnh';

      if (savedNgayBatDau != null && savedNgayKetThuc != null) {
        try {
          final partsBatDau = savedNgayBatDau.split('/');
          final partsKetThuc = savedNgayKetThuc.split('/');
          _ngayBatDau = DateTime(
            int.parse(partsBatDau[2]),
            int.parse(partsBatDau[1]),
            int.parse(partsBatDau[0]),
          );
          _ngayKetThuc = DateTime(
            int.parse(partsKetThuc[2]),
            int.parse(partsKetThuc[1]),
            int.parse(partsKetThuc[0]),
          );
        } catch (e) {
          _ngayBatDau = DateTime.now();
          _ngayKetThuc = DateTime.now();
        }
      } else {
        _ngayBatDau = DateTime.now();
        _ngayKetThuc = DateTime.now();
      }

      _ngayBatDauController.text =
          '${_ngayBatDau.day.toString().padLeft(2, '0')}/${_ngayBatDau.month.toString().padLeft(2, '0')}/${_ngayBatDau.year}';
      _ngayKetThucController.text =
          '${_ngayKetThuc.day.toString().padLeft(2, '0')}/${_ngayKetThuc.month.toString().padLeft(2, '0')}/${_ngayKetThuc.year}';
      _isLoading = false;
    });
  }

  Future<void> _saveMoTaMucTieu() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_currentUserPhone}_moTaMucTieu', _moTaMucTieuController.text);
  }

  Future<void> _saveThoiGianMucTieu() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_currentUserPhone}_ngayBatDauMucTieu', _ngayBatDauController.text);
    await prefs.setString('${_currentUserPhone}_ngayKetThucMucTieu', _ngayKetThucController.text);
    await prefs.setString('${_currentUserPhone}_khoangThoiGianMucTieu', _khoangThoiGian);
  }

  Future<void> _chonNgayBatDau() async {
    final DateTime? ngayChon = await showDatePicker(
      context: context,
      initialDate: _ngayBatDau,
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

    if (ngayChon != null && ngayChon != _ngayBatDau) {
      setState(() {
        _ngayBatDau = ngayChon;
        _ngayBatDauController.text =
            '${ngayChon.day.toString().padLeft(2, '0')}/${ngayChon.month.toString().padLeft(2, '0')}/${ngayChon.year}';
        _capNhatNgayKetThuc();
      });
    }
  }

  Future<void> _chonNgayKetThuc() async {
    final DateTime? ngayChon = await showDatePicker(
      context: context,
      initialDate: _ngayKetThuc,
      firstDate: _ngayBatDau,
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

    if (ngayChon != null && ngayChon != _ngayKetThuc) {
      setState(() {
        _ngayKetThuc = ngayChon;
        _ngayKetThucController.text =
            '${ngayChon.day.toString().padLeft(2, '0')}/${ngayChon.month.toString().padLeft(2, '0')}/${ngayChon.year}';
      });
    }
  }

  void _capNhatNgayKetThuc() {
    DateTime ngayKetThucMoi = _ngayBatDau;
    switch (_khoangThoiGian) {
      case '1 tuần':
        ngayKetThucMoi = _ngayBatDau.add(const Duration(days: 7));
        break;
      case '1 tháng':
        ngayKetThucMoi = DateTime(_ngayBatDau.year, _ngayBatDau.month + 1, _ngayBatDau.day);
        break;
      case '1 năm':
        ngayKetThucMoi = DateTime(_ngayBatDau.year + 1, _ngayBatDau.month, _ngayBatDau.day);
        break;
      case 'Tùy chỉnh':
        return;
    }
    setState(() {
      _ngayKetThuc = ngayKetThucMoi;
      _ngayKetThucController.text =
          '${_ngayKetThuc.day.toString().padLeft(2, '0')}/${_ngayKetThuc.month.toString().padLeft(2, '0')}/${_ngayKetThuc.year}';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
                  'Quản Lý Mục Tiêu',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thiết Lập Mục Tiêu',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _mucTieuController,
                            decoration: InputDecoration(
                              labelText: 'Số tiền mục tiêu (VNĐ)',
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
                              NumberFormatter(),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _moTaMucTieuController,
                            decoration: InputDecoration(
                              labelText: 'Mô tả mục tiêu',
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
                          DropdownButtonFormField<String>(
                            value: _khoangThoiGian,
                            decoration: InputDecoration(
                              labelText: 'Khoảng thời gian',
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
                            items: const [
                              DropdownMenuItem(value: '1 tuần', child: Text('1 tuần')),
                              DropdownMenuItem(value: '1 tháng', child: Text('1 tháng')),
                              DropdownMenuItem(value: '1 năm', child: Text('1 năm')),
                              DropdownMenuItem(value: 'Tùy chỉnh', child: Text('Tùy chỉnh')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _khoangThoiGian = value!;
                                _capNhatNgayKetThuc();
                              });
                            },
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _ngayBatDauController,
                            decoration: InputDecoration(
                              labelText: 'Ngày bắt đầu',
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
                            onTap: _chonNgayBatDau,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _ngayKetThucController,
                            decoration: InputDecoration(
                              labelText: 'Ngày kết thúc',
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
                            onTap: _khoangThoiGian == 'Tùy chỉnh' ? _chonNgayKetThuc : null,
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                String rawMucTieu = _mucTieuController.text.replaceAll('.', '');
                                double newMucTieu = double.tryParse(rawMucTieu) ?? _mucTieu;

                                if (_ngayKetThuc.isBefore(_ngayBatDau)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Ngày kết thúc phải sau ngày bắt đầu!'),
                                      backgroundColor: Color(0xFFFF2D55),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  _mucTieu = newMucTieu;
                                });

                                _saveMoTaMucTieu();
                                _saveThoiGianMucTieu();
                                widget.onMucTieuUpdated?.call(_mucTieu, _ngayKetThuc);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã lưu mục tiêu tiết kiệm!'),
                                    backgroundColor: Color(0xFF34C759),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Lưu mục tiêu',
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thêm Tiền Tiết Kiệm',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _tienTietKiemController,
                            decoration: InputDecoration(
                              labelText: 'Số tiền tiết kiệm (VNĐ)',
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
                              NumberFormatter(),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tổng tiết kiệm hiện tại: ${_tongTienTietKiem == 0 ? '0' : _tongTienTietKiem.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ',
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                String rawTienTietKiem = _tienTietKiemController.text.replaceAll('.', '');
                                double tienTietKiem = double.tryParse(rawTienTietKiem) ?? 0.0;

                                if (tienTietKiem <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Vui lòng nhập số tiền hợp lệ!'),
                                      backgroundColor: Color(0xFFFF2D55),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }

                                if (tienTietKiem > widget.soDu) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Số tiền tiết kiệm không được vượt quá số dư hiện có!'),
                                      backgroundColor: Color(0xFFFF2D55),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  _tongTienTietKiem += tienTietKiem;
                                });

                                _tienTietKiemController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã thêm tiền tiết kiệm!'),
                                    backgroundColor: Color(0xFF34C759),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Thêm tiết kiệm',
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rút Tiền Tiết Kiệm',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _tienRutController,
                            decoration: InputDecoration(
                              labelText: 'Số tiền muốn rút (VNĐ)',
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
                                borderSide: const BorderSide(color: Color(0xFFFF2D55)),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              NumberFormatter(),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tổng tiết kiệm hiện tại: ${_tongTienTietKiem == 0 ? '0' : _tongTienTietKiem.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ',
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFFF2D55),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                String rawTienRut = _tienRutController.text.replaceAll('.', '');
                                double tienRut = double.tryParse(rawTienRut) ?? 0.0;

                                if (tienRut <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Vui lòng nhập số tiền hợp lệ!'),
                                      backgroundColor: Color(0xFFFF2D55),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }

                                if (tienRut > _tongTienTietKiem) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Số tiền rút vượt quá số tiền tiết kiệm hiện có!'),
                                      backgroundColor: Color(0xFFFF2D55),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  _tongTienTietKiem -= tienRut;
                                });

                                _tienRutController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã rút tiền tiết kiệm!'),
                                    backgroundColor: Color(0xFF34C759),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF2D55),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Rút tiền',
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
                            onTap: () {
                              String rawMucTieu = _mucTieuController.text.replaceAll('.', '');
                              double newMucTieu = double.tryParse(rawMucTieu) ?? _mucTieu;

                              if (_ngayKetThuc.isBefore(_ngayBatDau)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Ngày kết thúc phải sau ngày bắt đầu!'),
                                    backgroundColor: Color(0xFFFF2D55),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                _mucTieu = newMucTieu;
                              });

                              _saveMoTaMucTieu();
                              _saveThoiGianMucTieu();
                              widget.onMucTieuUpdated?.call(_mucTieu, _ngayKetThuc);
                              Navigator.pop(context, {
                                'mucTieu': _mucTieu,
                                'tongTienTietKiem': _tongTienTietKiem,
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
                                  'Lưu',
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
}