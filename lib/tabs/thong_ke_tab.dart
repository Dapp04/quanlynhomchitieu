// ignore_for_file: deprecated_member_use, avoid_print, unused_local_variable, library_private_types_in_public_api, unused_field

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:qlct/widgets/thong_ke_widgets.dart';
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
            'gradientColors': [const Color(0xFF40C4FF), const Color(0xFF81D4FA)],
            'primaryColor': const Color(0xFF40C4FF)
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
                    giaoDich.loai == 'Chi tiêu' ? const Color(0xFFEF5350) : const Color(0xFF4CAF50),
                duration: const Duration(seconds: 3),
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
                  'gradientColors': [const Color(0xFF40C4FF), const Color(0xFF81D4FA)],
                  'primaryColor': const Color(0xFF40C4FF)
                },
          )
        : {
            'name': 'Light Teal',
            'gradientColors': [const Color(0xFF40C4FF), const Color(0xFF81D4FA)],
            'primaryColor': const Color(0xFF40C4FF)
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

    // Lấy nguồn khoản lớn nhất
    MapEntry<String, double>? nguonKhoanChiTieuLonNhat = danhSachNguonKhoanChiTieu.isNotEmpty ? danhSachNguonKhoanChiTieu.first : null;
    MapEntry<String, double>? nguonKhoanThuNhapLonNhat = danhSachNguonKhoanThuNhap.isNotEmpty ? danhSachNguonKhoanThuNhap.first : null;

    print('Debug: danhSachGiaoDich.length = ${danhSachGiaoDich.length}');

    return SafeArea(
      child: Container(
        color: const Color(0xFFF5F7FA),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: currentTheme['gradientColors'],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Thống Kê',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Savings Goal Section
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTapDown: (_) => _animationController.forward(),
                          onTapUp: (_) => _animationController.reverse(),
                          onTapCancel: () => _animationController.reverse(),
                          onTap: _navigateToQuanLyMucTieu,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (_mucTieu['amount'] > 0) ...[
                                  SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          value: (_tongTienTietKiem / _mucTieu['amount']).clamp(0.0, 1.0),
                                          strokeWidth: 6,
                                          backgroundColor: Colors.grey[200],
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                              currentTheme['primaryColor']),
                                        ),
                                        Text(
                                          '${((_tongTienTietKiem / _mucTieu['amount']) * 100).toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
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
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF212121),
                                        ),
                                      ),
                                      if (_mucTieu['amount'] > 0) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          '${_tongTienTietKiem.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} / ${_mucTieu['amount'].toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 16,
                                            color: currentTheme['primaryColor'],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Hạn: ${DateFormat('dd/MM/yy').format(_mucTieu['deadline'].toLocal())}',
                                          style: const TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 14,
                                            color: Color(0xFF616161),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: currentTheme['primaryColor'],
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (danhSachGiaoDich.isNotEmpty) ...[
                      // Time Period Selection
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          child: Center(
                            child: SegmentedButton<int>(
                              segments: const [
                                ButtonSegment(
                                  value: 0,
                                  label: Text('Tuần', style: TextStyle(fontFamily: 'Roboto')),
                                  icon: Icon(Icons.calendar_view_week, size: 20),
                                ),
                                ButtonSegment(
                                  value: 1,
                                  label: Text('Tháng', style: TextStyle(fontFamily: 'Roboto')),
                                  icon: Icon(Icons.calendar_view_month, size: 20),
                                ),
                                ButtonSegment(
                                  value: 2,
                                  label: Text('Năm', style: TextStyle(fontFamily: 'Roboto')),
                                  icon: Icon(Icons.calendar_today, size: 20),
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
                                selectedBackgroundColor: currentTheme['primaryColor'],
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                textStyle: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Income/Expense Toggle
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: buildToggleButton(
                                  title: 'Chi tiêu',
                                  isSelected: hienThiChiTieu,
                                  onTap: () => setState(() => hienThiChiTieu = true),
                                  color: const Color(0xFFEF5350),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                child: buildToggleButton(
                                  title: 'Thu nhập',
                                  isSelected: !hienThiChiTieu,
                                  onTap: () => setState(() => hienThiChiTieu = false),
                                  color: const Color(0xFF4CAF50),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Statistics Content
                      if (danhSachLoc.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.pie_chart_outline,
                                size: 80,
                                color: currentTheme['primaryColor'].withOpacity(0.6),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Chưa có dữ liệu thống kê',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  color: Colors.grey[600],
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Summary Section
                            Row(
                              children: [
                                Expanded(
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: buildSummaryCard(
                                      title: 'Tổng chi tiêu',
                                      value: tongChiTieuLoc,
                                      color: const Color(0xFFEF5350),
                                      icon: Icons.arrow_downward,
                                      isVisible: hienThiChiTieu,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: buildSummaryCard(
                                      title: 'Tổng thu nhập',
                                      value: tongThuNhapLoc,
                                      color: const Color(0xFF4CAF50),
                                      icon: Icons.arrow_upward,
                                      isVisible: !hienThiChiTieu,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Largest Group Section
                            if ((hienThiChiTieu &&
                                    nhomChiTieuLonNhatLoc != null &&
                                    nhomChiTieuLonNhatLoc.value > 0) ||
                                (!hienThiChiTieu &&
                                    nhomThuNhapLonNhatLoc != null &&
                                    nhomThuNhapLonNhatLoc.value > 0))
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      buildSectionHeader(
                                        title: 'Nhóm lớn nhất',
                                        icon: Icons.trending_up_rounded,
                                        color: currentTheme['primaryColor'],
                                      ),
                                      const SizedBox(height: 16),
                                      if (hienThiChiTieu &&
                                          nhomChiTieuLonNhatLoc != null &&
                                          nhomChiTieuLonNhatLoc.value > 0)
                                        buildLargestItemCard(
                                          title: nhomChiTieuLonNhatLoc.key,
                                          value: nhomChiTieuLonNhatLoc.value,
                                          color: const Color(0xFFEF5350),
                                          icon: Icons.trending_up,
                                        ),
                                      if (!hienThiChiTieu &&
                                          nhomThuNhapLonNhatLoc != null &&
                                          nhomThuNhapLonNhatLoc.value > 0)
                                        buildLargestItemCard(
                                          title: nhomThuNhapLonNhatLoc.key,
                                          value: nhomThuNhapLonNhatLoc.value,
                                          color: const Color(0xFF4CAF50),
                                          icon: Icons.trending_up,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                            // Largest Fund Source Section
                            if ((hienThiChiTieu &&
                                    nguonKhoanChiTieuLonNhat != null &&
                                    nguonKhoanChiTieuLonNhat.value > 0) ||
                                (!hienThiChiTieu &&
                                    nguonKhoanThuNhapLonNhat != null &&
                                    nguonKhoanThuNhapLonNhat.value > 0))
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      buildSectionHeader(
                                        title: 'Nguồn khoản lớn nhất',
                                        icon: Icons.account_balance_wallet_rounded,
                                        color: currentTheme['primaryColor'],
                                      ),
                                      const SizedBox(height: 16),
                                      if (hienThiChiTieu &&
                                          nguonKhoanChiTieuLonNhat != null &&
                                          nguonKhoanChiTieuLonNhat.value > 0)
                                        buildLargestItemCard(
                                          title: nguonKhoanChiTieuLonNhat.key,
                                          value: nguonKhoanChiTieuLonNhat.value,
                                          color: const Color(0xFFEF5350),
                                          icon: Icons.trending_up,
                                        ),
                                      if (!hienThiChiTieu &&
                                          nguonKhoanThuNhapLonNhat != null &&
                                          nguonKhoanThuNhapLonNhat.value > 0)
                                        buildLargestItemCard(
                                          title: nguonKhoanThuNhapLonNhat.key,
                                          value: nguonKhoanThuNhapLonNhat.value,
                                          color: const Color(0xFF4CAF50),
                                          icon: Icons.trending_up,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                            // Group Rankings Section
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildSectionHeader(
                                      title: 'Xếp hạng nhóm',
                                      icon: Icons.category_rounded,
                                      color: currentTheme['primaryColor'],
                                    ),
                                    const SizedBox(height: 16),
                                    if (hienThiChiTieu) ...[
                                      if (danhSachChiTieu.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 20),
                                          child: Text(
                                            'Chưa có dữ liệu chi tiêu',
                                            style: TextStyle(
                                              fontFamily: 'Roboto',
                                              color: Colors.grey[600],
                                              fontSize: 16,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      else
                                        ...danhSachChiTieu.map((entry) {
                                          if (entry.value == 0) return const SizedBox.shrink();
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: buildGroupBar(
                                              context: context,
                                              groupName: entry.key,
                                              amount: entry.value,
                                              maxAmount: maxChiTieu,
                                              isChiTieu: true,
                                            ),
                                          );
                                        }),
                                    ] else ...[
                                      if (danhSachThuNhap.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 20),
                                          child: Text(
                                            'Chưa có dữ liệu thu nhập',
                                            style: TextStyle(
                                              fontFamily: 'Roboto',
                                              color: Colors.grey[600],
                                              fontSize: 16,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      else
                                        ...danhSachThuNhap.map((entry) {
                                          if (entry.value == 0) return const SizedBox.shrink();
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: buildGroupBar(
                                              context: context,
                                              groupName: entry.key,
                                              amount: entry.value,
                                              maxAmount: maxThuNhap,
                                              isChiTieu: false,
                                            ),
                                          );
                                        }),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Account Rankings Section
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildSectionHeader(
                                      title: 'Xếp hạng nguồn khoản',
                                      icon: Icons.account_balance_wallet_rounded,
                                      color: currentTheme['primaryColor'],
                                    ),
                                    const SizedBox(height: 16),
                                    if (danhSachNguonKhoan.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 20),
                                        child: Text(
                                          hienThiChiTieu
                                              ? 'Chưa có dữ liệu chi tiêu cho nguồn khoản'
                                              : 'Chưa có dữ liệu thu nhập cho nguồn khoản',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    else
                                      ...danhSachNguonKhoan.map((entry) {
                                        if (entry.value == 0) return const SizedBox.shrink();
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: buildGroupBar(
                                            context: context,
                                            groupName: entry.key,
                                            amount: entry.value,
                                            maxAmount: maxNguonKhoan,
                                            isChiTieu: hienThiChiTieu,
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 100),
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

  Widget buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
        ),
      ],
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
          width: 120,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }
}