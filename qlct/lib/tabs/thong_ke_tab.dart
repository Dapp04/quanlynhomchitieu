// ignore_for_file: deprecated_member_use, avoid_print, unused_local_variable, library_private_types_in_public_api, unused_field

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/giao_dich.dart';
import '../screens/manhinh_quanlymuctieu.dart';
import '../services/notification_service.dart';

class ThongKeTab extends StatefulWidget {
  final List<GiaoDich> danhSachGiaoDich;
  final double tongChiTieu;
  final double tongThuNhap;
  final MapEntry<String, double>? nhomChiTieuLonNhat;
  final MapEntry<String, double>? nhomThuNhapLonNhat;
  final Map<String, double> chiTieuHienTai;
  final Map<String, double> thuNhapHienTai;
  final double soDu;

  const ThongKeTab({
    super.key,
    required this.danhSachGiaoDich,
    required this.tongChiTieu,
    required this.tongThuNhap,
    required this.nhomChiTieuLonNhat,
    required this.nhomThuNhapLonNhat,
    required this.chiTieuHienTai,
    required this.thuNhapHienTai,
    required this.soDu,
  });

  @override
  _ThongKeTabState createState() => _ThongKeTabState();
}

class _ThongKeTabState extends State<ThongKeTab> with SingleTickerProviderStateMixin {
  bool hienThiChiTieu = true;
  int khoangThoiGian = 1;
  final Map<String, dynamic> _mucTieu = {'amount': 0.0, 'deadline': DateTime.now()};
  double _tongTienTietKiem = 0.0;
  bool daCanhBao = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  late List<GiaoDich> danhSachGiaoDich;
  late double tongChiTieu;
  late double tongThuNhap;
  late MapEntry<String, double>? nhomChiTieuLonNhat;
  late MapEntry<String, double>? nhomThuNhapLonNhat;
  late Map<String, double> chiTieuHienTai;
  late Map<String, double> thuNhapHienTai;
  late double soDu;

  List<GiaoDich> _previousDanhSachGiaoDich = [];
  List<Map<String, dynamic>> _themes = [];
  String _selectedTheme = 'Light Teal';
  bool _isLoading = true;
  String _currentUserPhone = '';

  List<Map<String, dynamic>> _danhSachKhoanSoDu = [];

  @override
  void initState() {
    super.initState();
    danhSachGiaoDich = widget.danhSachGiaoDich;
    tongChiTieu = widget.tongChiTieu;
    tongThuNhap = widget.tongThuNhap;
    nhomChiTieuLonNhat = widget.nhomChiTieuLonNhat;
    nhomThuNhapLonNhat = widget.nhomThuNhapLonNhat;
    chiTieuHienTai = widget.chiTieuHienTai;
    thuNhapHienTai = widget.thuNhapHienTai;
    soDu = widget.soDu;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadCurrentUserPhone();

    if (danhSachGiaoDich.isNotEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _kiemTraMucTieu();
      });
    }
  }

  Future<void> _loadCurrentUserPhone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _currentUserPhone = prefs.getString('currentUserPhone') ?? '';
        _loadThemesAndData();
      });
    } catch (e) {
      print('Lỗi khi tải thông tin người dùng: $e');
      setState(() {
        _currentUserPhone = '';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadThemesAndData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String>? savedKhoanSoDu = prefs.getStringList('${_currentUserPhone}_danhSachKhoanSoDu');
      if (savedKhoanSoDu != null) {
        _danhSachKhoanSoDu = savedKhoanSoDu.map((item) {
          final parts = item.split('|');
          return {
            'loai': parts[0],
            'ten': parts[1],
            'soTien': double.tryParse(parts[2]) ?? 0.0,
            'nganHang': parts.length > 3 ? parts[3] : null,
          };
        }).toList();
      } else {
        _danhSachKhoanSoDu = [];
      }

      setState(() {
        _themes = [
          {
            'name': 'Light Teal',
            'primaryColor': const Color(0xFF6366F1),
          },
        ];
        _selectedTheme = prefs.getString('${_currentUserPhone}_selectedTheme') ?? 'Light Teal';
        _mucTieu['amount'] = prefs.getDouble('${_currentUserPhone}_mucTieu') ?? 0.0;
        _mucTieu['deadline'] = DateTime.fromMillisecondsSinceEpoch(
            prefs.getInt('${_currentUserPhone}_mucTieuDeadline') ?? DateTime.now().millisecondsSinceEpoch);
        _tongTienTietKiem = prefs.getDouble('${_currentUserPhone}_tongTienTietKiem') ?? 0.0;
        _isLoading = false;
      });
    } catch (e) {
      print('Lỗi khi tải dữ liệu thống kê: $e');
      setState(() {
        _danhSachKhoanSoDu = [];
        _themes = [
          {
            'name': 'Light Teal',
            'primaryColor': const Color(0xFF6366F1),
          },
        ];
        _selectedTheme = 'Light Teal';
        _mucTieu['amount'] = 0.0;
        _mucTieu['deadline'] = DateTime.now();
        _tongTienTietKiem = 0.0;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveMucTieu() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('${_currentUserPhone}_mucTieu', _mucTieu['amount']);
    await prefs.setInt('${_currentUserPhone}_mucTieuDeadline', _mucTieu['deadline'].millisecondsSinceEpoch);
  }

  Future<void> _saveTongTienTietKiem() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('${_currentUserPhone}_tongTienTietKiem', _tongTienTietKiem);
  }

  @override
  void didUpdateWidget(ThongKeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.danhSachGiaoDich != widget.danhSachGiaoDich) {
      final newTransactions = widget.danhSachGiaoDich
          .where((giaoDich) => !_previousDanhSachGiaoDich.contains(giaoDich))
          .toList();
      if (newTransactions.isNotEmpty) {
        for (var giaoDich in newTransactions) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            final String formattedSoTien = giaoDich.soTien.toStringAsFixed(0).replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
            final String sign = giaoDich.loai == 'Thu nhập' ? '+' : '-';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Giao dịch mới: $sign $formattedSoTien VNĐ (${giaoDich.loai})'),
                backgroundColor:
                    giaoDich.loai == 'Chi tiêu' ? const Color(0xFFFF2D55) : const Color(0xFF34C759),
                duration: const Duration(seconds: 2),
              ),
            );
          });
        }
      }
      _previousDanhSachGiaoDich = List.from(widget.danhSachGiaoDich);
    }
    if (oldWidget.tongChiTieu != widget.tongChiTieu || oldWidget.tongThuNhap != widget.tongThuNhap) {
      setState(() {
        danhSachGiaoDich = widget.danhSachGiaoDich;
        tongChiTieu = widget.tongChiTieu;
        tongThuNhap = widget.tongThuNhap;
        nhomChiTieuLonNhat = widget.nhomChiTieuLonNhat;
        nhomThuNhapLonNhat = widget.nhomThuNhapLonNhat;
        chiTieuHienTai = widget.chiTieuHienTai;
        thuNhapHienTai = widget.thuNhapHienTai;
        soDu = widget.soDu;
      });
      if (danhSachGiaoDich.isNotEmpty) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _kiemTraMucTieu();
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<GiaoDich> locTheoKhoangThoiGian(List<GiaoDich> giaoDichList, int khoangThoiGian) {
    DateTime now = DateTime.now();
    List<GiaoDich> danhSachLoc = [];

    for (var giaoDich in giaoDichList) {
      DateTime ngayGiaoDich = giaoDich.ngayGio;

      switch (khoangThoiGian) {
        case 0: // Tuần
          DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
          if (ngayGiaoDich.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              ngayGiaoDich.isBefore(endOfWeek.add(const Duration(days: 1)))) {
            danhSachLoc.add(giaoDich);
          }
          break;

        case 1: // Tháng
          if (ngayGiaoDich.month == now.month && ngayGiaoDich.year == now.year) {
            danhSachLoc.add(giaoDich);
          }
          break;

        case 2: // Năm
          if (ngayGiaoDich.year == now.year) {
            danhSachLoc.add(giaoDich);
          }
          break;
      }
    }
    print('Debug: danhSachLoc.length = ${danhSachLoc.length} for khoangThoiGian = $khoangThoiGian');
    return danhSachLoc;
  }

  Map<String, dynamic> tinhToanThongKe(List<GiaoDich> danhSachLoc) {
    double tongChiTieuLoc = 0.0;
    double tongThuNhapLoc = 0.0;
    Map<String, double> chiTieuTheoNhom = {};
    Map<String, double> thuNhapTheoNhom = {};
    Map<String, double> chiTieuTheoNguonKhoan = {};
    Map<String, double> thuNhapTheoNguonKhoan = {};
    MapEntry<String, double>? nhomChiTieuLonNhatLoc;
    MapEntry<String, double>? nhomThuNhapLonNhatLoc;

    for (var giaoDich in danhSachLoc) {
      String tenKhoan = giaoDich.tenKhoan.isNotEmpty ? giaoDich.tenKhoan : 'Không xác định';
      if (giaoDich.loai == 'Chi tiêu') {
        tongChiTieuLoc += giaoDich.soTien;
        chiTieuTheoNhom[giaoDich.nhom] = (chiTieuTheoNhom[giaoDich.nhom] ?? 0) + giaoDich.soTien;
        chiTieuTheoNguonKhoan[tenKhoan] = (chiTieuTheoNguonKhoan[tenKhoan] ?? 0) + giaoDich.soTien;
      } else {
        tongThuNhapLoc += giaoDich.soTien;
        thuNhapTheoNhom[giaoDich.nhom] = (thuNhapTheoNhom[giaoDich.nhom] ?? 0) + giaoDich.soTien;
        thuNhapTheoNguonKhoan[tenKhoan] = (thuNhapTheoNguonKhoan[tenKhoan] ?? 0) + giaoDich.soTien;
      }
    }

    if (chiTieuTheoNhom.isNotEmpty) {
      nhomChiTieuLonNhatLoc = chiTieuTheoNhom.entries.reduce((a, b) => a.value > b.value ? a : b);
    }

    if (thuNhapTheoNhom.isNotEmpty) {
      nhomThuNhapLonNhatLoc = thuNhapTheoNhom.entries.reduce((a, b) => a.value > b.value ? a : b);
    }

    return {
      'tongChiTieuLoc': tongChiTieuLoc,
      'tongThuNhapLoc': tongThuNhapLoc,
      'chiTieuTheoNhom': chiTieuTheoNhom,
      'thuNhapTheoNhom': thuNhapTheoNhom,
      'nhomChiTieuLonNhatLoc': nhomChiTieuLonNhatLoc,
      'nhomThuNhapLonNhatLoc': nhomThuNhapLonNhatLoc,
      'chiTieuTheoNguonKhoan': chiTieuTheoNguonKhoan,
      'thuNhapTheoNguonKhoan': thuNhapTheoNguonKhoan,
    };
  }

  void _kiemTraMucTieu() async {
    final now = DateTime.now();
    if (_mucTieu['amount'] > 0 && !daCanhBao) {
      if (now.isAfter(_mucTieu['deadline'])) {
        if (_tongTienTietKiem < _mucTieu['amount']) {
          await NotificationService.showNotification(
            id: 3,
            title: 'Cảnh báo mục tiêu tiết kiệm',
            body: 'Đã đến hạn nhưng chưa đủ tiền!',
          );
          daCanhBao = true;
        } else {
          final daysEarly = _mucTieu['deadline'].difference(now).inDays.abs();
          final status = daysEarly > 0 ? 'sớm $daysEarly ngày' : 'trúng hạn';
          await NotificationService.showNotification(
            id: 4,
            title: 'Chúc mừng!',
            body: 'Bạn đã đạt mục tiêu tiết kiệm $status!',
          );
          daCanhBao = true;
        }
      } else if (_tongTienTietKiem >= _mucTieu['amount']) {
        final daysEarly = _mucTieu['deadline'].difference(now).inDays.abs();
        final status = daysEarly > 0 ? 'sớm $daysEarly ngày' : 'trúng hạn';
        await NotificationService.showNotification(
            id: 4,
            title: 'Chúc mừng!',
            body: 'Bạn đã đạt mục tiêu tiết kiệm $status!',
        );
        daCanhBao = true;
      }
    } else if (_tongTienTietKiem >= _mucTieu['amount']) {
      daCanhBao = false;
    }
  }

  void _navigateToQuanLyMucTieu() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManHinhQuanLyMucTieu(
          mucTieu: _mucTieu['amount'],
          tongTienTietKiem: _tongTienTietKiem,
          soDu: soDu,
          onMucTieuUpdated: (newMucTieu, newDeadline) {
            setState(() {
              _mucTieu['amount'] = newMucTieu;
              _mucTieu['deadline'] = newDeadline;
            });
            _saveMucTieu();
            _kiemTraMucTieu();
          },
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _mucTieu['amount'] = result['mucTieu'] ?? _mucTieu['amount'];
        _tongTienTietKiem = result['tongTienTietKiem'] ?? _tongTienTietKiem;
      });
      _saveMucTieu();
      _saveTongTienTietKiem();
      _kiemTraMucTieu();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentTheme = _themes.isNotEmpty
        ? _themes.firstWhere(
            (t) => t['name'] == _selectedTheme,
            orElse: () => {
                  'name': 'Light Teal',
                  'primaryColor': const Color(0xFF6366F1),
                },
          )
        : {
            'name': 'Light Teal',
            'primaryColor': const Color(0xFF6366F1),
          };

    final danhSachLoc = locTheoKhoangThoiGian(danhSachGiaoDich, khoangThoiGian);
    final thongKe = tinhToanThongKe(danhSachLoc);
    double tongChiTieuLoc = thongKe['tongChiTieuLoc'];
    double tongThuNhapLoc = thongKe['tongThuNhapLoc'];
    Map<String, double> chiTieuTheoNhom = thongKe['chiTieuTheoNhom'];
    Map<String, double> thuNhapTheoNhom = thongKe['thuNhapTheoNhom'];
    Map<String, double> chiTieuTheoNguonKhoan = thongKe['chiTieuTheoNguonKhoan'];
    Map<String, double> thuNhapTheoNguonKhoan = thongKe['thuNhapTheoNguonKhoan'];
    MapEntry<String, double>? nhomChiTieuLonNhatLoc = thongKe['nhomChiTieuLonNhatLoc'];
    MapEntry<String, double>? nhomThuNhapLonNhatLoc = thongKe['nhomThuNhapLonNhatLoc'];

    List<MapEntry<String, double>> danhSachChiTieu = chiTieuTheoNhom.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    List<MapEntry<String, double>> danhSachThuNhap = thuNhapTheoNhom.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    List<MapEntry<String, double>> danhSachNguonKhoanChiTieu = chiTieuTheoNguonKhoan.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    List<MapEntry<String, double>> danhSachNguonKhoanThuNhap = thuNhapTheoNguonKhoan.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    double maxChiTieu = danhSachChiTieu.isNotEmpty ? danhSachChiTieu.first.value : 1.0;
    double maxThuNhap = danhSachThuNhap.isNotEmpty ? danhSachThuNhap.first.value : 1.0;
    double maxNguonKhoanChiTieu = danhSachNguonKhoanChiTieu.isNotEmpty ? danhSachNguonKhoanChiTieu.first.value : 1.0;
    double maxNguonKhoanThuNhap = danhSachNguonKhoanThuNhap.isNotEmpty ? danhSachNguonKhoanThuNhap.first.value : 1.0;

    List<MapEntry<String, double>> danhSachNguonKhoan = hienThiChiTieu
        ? danhSachNguonKhoanChiTieu
        : danhSachNguonKhoanThuNhap;
    double maxNguonKhoan = hienThiChiTieu ? maxNguonKhoanChiTieu : maxNguonKhoanThuNhap;

    MapEntry<String, double>? nguonKhoanChiTieuLonNhat = danhSachNguonKhoanChiTieu.isNotEmpty ? danhSachNguonKhoanChiTieu.first : null;
    MapEntry<String, double>? nguonKhoanThuNhapLonNhat = danhSachNguonKhoanThuNhap.isNotEmpty ? danhSachNguonKhoanThuNhap.first : null;

    return Container(
      color: const Color(0xFFF5F7FA),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              color: const Color(0xFF6366F1),
              child: const Center(
                child: Text(
                  'Thống Kê',
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
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTapDown: (_) => _animationController.forward(),
                          onTapUp: (_) => _animationController.reverse(),
                          onTapCancel: () => _animationController.reverse(),
                          onTap: _navigateToQuanLyMucTieu,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (_mucTieu['amount'] > 0) ...[
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        value: (_tongTienTietKiem / _mucTieu['amount']).clamp(0.0, 1.0),
                                        strokeWidth: 4,
                                        backgroundColor: Colors.grey[200],
                                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                                      ),
                                      Text(
                                        '${((_tongTienTietKiem / _mucTieu['amount']) * 100).toStringAsFixed(0)}%',
                                        style: const TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _mucTieu['amount'] == 0
                                          ? 'Thiết lập mục tiêu'
                                          : 'Mục tiêu tiết kiệm',
                                      style: const TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    if (_mucTieu['amount'] > 0) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        '${_tongTienTietKiem.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} / ${_mucTieu['amount'].toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ',
                                        style: const TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 14,
                                          color: Color(0xFF6366F1),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        'Hạn: ${DateFormat('dd/MM/yy').format(_mucTieu['deadline'].toLocal())}',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF6366F1),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (danhSachGiaoDich.isNotEmpty) ...[
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
                        child: SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(
                              value: 0,
                              label: Text('Tuần', style: TextStyle(fontFamily: 'Roboto', fontSize: 14)),
                            ),
                            ButtonSegment(
                              value: 1,
                              label: Text('Tháng', style: TextStyle(fontFamily: 'Roboto', fontSize: 14)),
                            ),
                            ButtonSegment(
                              value: 2,
                              label: Text('Năm', style: TextStyle(fontFamily: 'Roboto', fontSize: 14)),
                            ),
                          ],
                          selected: {khoangThoiGian},
                          onSelectionChanged: (newSelection) {
                            setState(() {
                              khoangThoiGian = newSelection.first;
                            });
                          },
                          style: SegmentedButton.styleFrom(
                            selectedForegroundColor: Colors.white,
                            selectedBackgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            textStyle: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            side: BorderSide(color: Colors.grey.shade300, width: 1),
                          ),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: buildToggleButton(
                                title: 'Chi tiêu',
                                isSelected: hienThiChiTieu,
                                onTap: () => setState(() => hienThiChiTieu = true),
                                color: const Color(0xFFFF2D55),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: buildToggleButton(
                                title: 'Thu nhập',
                                isSelected: !hienThiChiTieu,
                                onTap: () => setState(() => hienThiChiTieu = false),
                                color: const Color(0xFF34C759),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (danhSachLoc.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.pie_chart_outline,
                                size: 48,
                                color: const Color(0xFF6366F1).withOpacity(0.6),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Chưa có dữ liệu thống kê',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
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
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tổng chi tiêu',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${tongChiTieuLoc.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ',
                                          style: const TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFF2D55),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
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
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tổng thu nhập',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${tongThuNhapLoc.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ',
                                          style: const TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF34C759),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if ((hienThiChiTieu &&
                                    nhomChiTieuLonNhatLoc != null &&
                                    nhomChiTieuLonNhatLoc.value > 0) ||
                                (!hienThiChiTieu &&
                                    nhomThuNhapLonNhatLoc != null &&
                                    nhomThuNhapLonNhatLoc.value > 0) ||
                                (hienThiChiTieu &&
                                    nguonKhoanChiTieuLonNhat != null &&
                                    nguonKhoanChiTieuLonNhat.value > 0) ||
                                (!hienThiChiTieu &&
                                    nguonKhoanThuNhapLonNhat != null &&
                                    nguonKhoanThuNhapLonNhat.value > 0))
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
                                      'Tổng quan',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (hienThiChiTieu &&
                                        nhomChiTieuLonNhatLoc != null &&
                                        nhomChiTieuLonNhatLoc.value > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Nhóm lớn nhất: ${nhomChiTieuLonNhatLoc.key}',
                                                    style: const TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${nhomChiTieuLonNhatLoc.value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ',
                                                    style: const TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontSize: 14,
                                                      color: Color(0xFFFF2D55),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (!hienThiChiTieu &&
                                        nhomThuNhapLonNhatLoc != null &&
                                        nhomThuNhapLonNhatLoc.value > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Nhóm lớn nhất: ${nhomThuNhapLonNhatLoc.key}',
                                                    style: const TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${nhomThuNhapLonNhatLoc.value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ',
                                                    style: const TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontSize: 14,
                                                      color: Color(0xFF34C759),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (hienThiChiTieu &&
                                        nguonKhoanChiTieuLonNhat != null &&
                                        nguonKhoanChiTieuLonNhat.value > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Nguồn khoản lớn nhất: ${nguonKhoanChiTieuLonNhat.key}',
                                                    style: const TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${nguonKhoanChiTieuLonNhat.value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ',
                                                    style: const TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontSize: 14,
                                                      color: Color(0xFFFF2D55),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (!hienThiChiTieu &&
                                        nguonKhoanThuNhapLonNhat != null &&
                                        nguonKhoanThuNhapLonNhat.value > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Nguồn khoản lớn nhất: ${nguonKhoanThuNhapLonNhat.key}',
                                                    style: const TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${nguonKhoanThuNhapLonNhat.value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ',
                                                    style: const TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontSize: 14,
                                                      color: Color(0xFF34C759),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
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
                                    'Xếp hạng nhóm',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (hienThiChiTieu) ...[
                                    if (danhSachChiTieu.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Chưa có dữ liệu chi tiêu',
                                              style: TextStyle(
                                                fontFamily: 'Roboto',
                                                color: Colors.grey.shade600,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
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
                                    else
                                      ...danhSachChiTieu.map((entry) {
                                        if (entry.value == 0) return const SizedBox.shrink();
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      entry.key,
                                                      style: const TextStyle(
                                                        fontFamily: 'Roboto',
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    '${entry.value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ',
                                                    style: const TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontSize: 14,
                                                      color: Color(0xFFFF2D55),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              LinearProgressIndicator(
                                                value: entry.value / maxChiTieu,
                                                backgroundColor: Colors.grey.shade200,
                                                color: const Color(0xFFFF2D55),
                                                minHeight: 4,
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                  ] else ...[
                                    if (danhSachThuNhap.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Chưa có dữ liệu thu nhập',
                                              style: TextStyle(
                                                fontFamily: 'Roboto',
                                                color: Colors.grey.shade600,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
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
                                    else
                                      ...danhSachThuNhap.map((entry) {
                                        if (entry.value == 0) return const SizedBox.shrink();
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      entry.key,
                                                      style: const TextStyle(
                                                        fontFamily: 'Roboto',
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    '${entry.value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ',
                                                    style: const TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontSize: 14,
                                                      color: Color(0xFF34C759),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              LinearProgressIndicator(
                                                value: entry.value / maxThuNhap,
                                                backgroundColor: Colors.grey.shade200,
                                                color: const Color(0xFF34C759),
                                                minHeight: 4,
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                  ],
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
                                    'Xếp hạng nguồn khoản',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (danhSachNguonKhoan.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            hienThiChiTieu
                                                ? 'Chưa có dữ liệu chi tiêu cho nguồn'
                                                : 'Chưa có dữ liệu thu nhập cho nguồn',
                                            style: TextStyle(
                                              fontFamily: 'Roboto',
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
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
                                  else
                                    ...danhSachNguonKhoan.map((entry) {
                                      if (entry.value == 0) return const SizedBox.shrink();
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    entry.key,
                                                    style: const TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '${entry.value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ',
                                                  style: TextStyle(
                                                    fontFamily: 'Roboto',
                                                    fontSize: 14,
                                                    color: hienThiChiTieu
                                                        ? const Color(0xFFFF2D55)
                                                        : const Color(0xFF34C759),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            LinearProgressIndicator(
                                              value: entry.value / maxNguonKhoan,
                                              backgroundColor: Colors.grey.shade200,
                                              color: hienThiChiTieu
                                                  ? const Color(0xFFFF2D55)
                                                  : const Color(0xFF34C759),
                                              minHeight: 4,
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 60),
                          ],
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildToggleButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        onTap();
      },
      onTapCancel: () => _animationController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}