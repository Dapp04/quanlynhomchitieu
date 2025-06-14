// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print, file_names
import 'package:flutter/material.dart';
import 'package:qlct/screens/manhinh_quanlymuctieu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../models/giao_dich.dart';
import '../utils/helpers.dart';
import '../tabs/trang_chu_tab.dart';
import '../tabs/giao_dich_tab.dart';
import '../tabs/thong_ke_tab.dart';
import '../tabs/ho_so_tab.dart';

class ManHinhTrangChu extends StatefulWidget {
  const ManHinhTrangChu({super.key});

  @override
  TrangThaiManHinhTrangChu createState() => TrangThaiManHinhTrangChu();
}

class TrangThaiManHinhTrangChu extends State<ManHinhTrangChu> with TickerProviderStateMixin {
  int chiSoDuocChon = 0;
  double soDu = 0.0;
  String ten = '';
  String soDienThoai = '';
  String? duongDanHinhDaiDien;
  List<GiaoDich> danhSachGiaoDich = [];
  int tabHienTai = 0;
  List<String> danhSachNhomChiTieu = [];
  List<String> danhSachNhomThuNhap = [];
  String _currentUserPhone = '';

  // Animation controllers for modern effects
  late AnimationController _fabAnimationController;
  late AnimationController _pageAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _pageTransitionAnimation;

  // Mục tiêu
  double mucTieuTietKiem = 1000000.0;
  double mucTieuChiTieuToiDa = 500000.0;
  double tongTienTietKiem = 0.0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadCurrentUserPhone();
  }

  void _initAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));

    _pageTransitionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageAnimationController,
      curve: Curves.easeInOutCubic,
    ));

    _pageAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _pageAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      setState(() {
        _currentUserPhone = prefs.getString('currentUserPhone') ?? '';
        _loadDanhSachNhom();
        _loadMucTieu();
        layDuLieu();
        taiDanhSachGiaoDich();
      });
    } catch (e) {
      print('Lỗi khi tải thông tin người dùng: $e');
      setState(() {
        _currentUserPhone = '';
      });
    }
  }

  Future<void> _loadDanhSachNhom() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final savedNhomChiTieu = prefs.getStringList('${_currentUserPhone}_danh_sach_nhom_chi_tieu');
      final savedNhomThuNhap = prefs.getStringList('${_currentUserPhone}_danh_sach_nhom_thu_nhap');
      setState(() {
        danhSachNhomChiTieu = savedNhomChiTieu ??
            ['Đồ ăn', 'Mua sắm', 'Giải trí', 'Du lịch', 'Học tập', 'Khác'];
        danhSachNhomThuNhap = savedNhomThuNhap ?? ['Lương', 'Trợ cấp', 'Thưởng', 'Khác'];
      });
    } catch (e) {
      print('Lỗi khi tải danh sách nhóm: $e');
      setState(() {
        danhSachNhomChiTieu = ['Đồ ăn', 'Mua sắm', 'Giải trí', 'Du lịch', 'Học tập', 'Khác'];
        danhSachNhomThuNhap = ['Lương', 'Trợ cấp', 'Thưởng', 'Khác'];
      });
    }
  }

  Future<void> _loadMucTieu() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      setState(() {
        mucTieuTietKiem = prefs.getDouble('${_currentUserPhone}_mucTieuTietKiem') ?? 1000000.0;
        mucTieuChiTieuToiDa = prefs.getDouble('${_currentUserPhone}_mucTieuChiTieuToiDa') ?? 500000.0;
        tongTienTietKiem = prefs.getDouble('${_currentUserPhone}_tongTienTietKiem') ?? 0.0;
      });
    } catch (e) {
      print('Lỗi khi tải mục tiêu: $e');
    }
  }

  Future<void> _saveDanhSachNhom() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setStringList('${_currentUserPhone}_danh_sach_nhom_chi_tieu', danhSachNhomChiTieu);
      await prefs.setStringList('${_currentUserPhone}_danh_sach_nhom_thu_nhap', danhSachNhomThuNhap);
    } catch (e) {
      print('Lỗi khi lưu danh sách nhóm: $e');
    }
  }

  Future<void> _saveMucTieu() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setDouble('${_currentUserPhone}_mucTieuTietKiem', mucTieuTietKiem);
      await prefs.setDouble('${_currentUserPhone}_mucTieuChiTieuToiDa', mucTieuChiTieuToiDa);
      await prefs.setDouble('${_currentUserPhone}_tongTienTietKiem', tongTienTietKiem);
    } catch (e) {
      print('Lỗi khi lưu mục tiêu: $e');
    }
  }

  Future<void> layDuLieu() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      setState(() {
        soDu = prefs.getDouble('${_currentUserPhone}_so_du') ?? 0.0;
        ten = prefs.getString('${_currentUserPhone}_ten') ?? 'Chưa cập nhật';
        soDienThoai = _currentUserPhone.isNotEmpty ? _currentUserPhone : 'Chưa cập nhật';
        String? storedImagePath = prefs.getString('${_currentUserPhone}_profileImage');
        duongDanHinhDaiDien = (storedImagePath != null && File(storedImagePath).existsSync())
            ? storedImagePath
            : null;
      });
    } catch (e) {
      print('Lỗi khi tải dữ liệu người dùng: $e');
      setState(() {
        soDu = 0.0;
        ten = 'Chưa cập nhật';
        soDienThoai = 'Chưa cập nhật';
        duongDanHinhDaiDien = null;
      });
    }
  }

  Future<void> taiDanhSachGiaoDich() async {
    final prefs = await SharedPreferences.getInstance();
    final String? giaoDichJson = prefs.getString('${_currentUserPhone}_danh_sach_giao_dich');
    try {
      if (giaoDichJson != null) {
        final List<dynamic> giaoDichList = jsonDecode(giaoDichJson);
        setState(() {
          danhSachGiaoDich = giaoDichList.map((json) => GiaoDich.fromJson(json)).toList();
        });
      } else {
        setState(() {
          danhSachGiaoDich = [];
        });
      }
    } catch (e) {
      print('Lỗi khi tải danh sách giao dịch: $e');
      setState(() {
        danhSachGiaoDich = [];
      });
    }
  }

  Future<void> xoaGiaoDich(int index) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final giaoDich = danhSachGiaoDich[index];
      double soDuMoi = prefs.getDouble('${_currentUserPhone}_so_du') ?? 0.0;

      if (giaoDich.loai == 'Thu nhập') {
        soDuMoi -= giaoDich.soTien;
      } else {
        soDuMoi += giaoDich.soTien;
      }
      soDuMoi = soDuMoi.clamp(0.0, double.infinity);

      setState(() {
        danhSachGiaoDich.removeAt(index);
        soDu = soDuMoi;
      });

      final String giaoDichMoiJson =
          jsonEncode(danhSachGiaoDich.map((giaoDich) => giaoDich.toJson()).toList());
      await prefs.setString('${_currentUserPhone}_danh_sach_giao_dich', giaoDichMoiJson);
      await prefs.setDouble('${_currentUserPhone}_so_du', soDuMoi);
    } catch (e) {
      print('Lỗi khi xóa giao dịch: $e');
    }
  }

  Future<void> capNhatGiaoDich(int index, GiaoDich giaoDichMoi) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      double soDuMoi = prefs.getDouble('${_currentUserPhone}_so_du') ?? 0.0;
      final giaoDichCu = danhSachGiaoDich[index];

      if (giaoDichCu.loai == 'Thu nhập') {
        soDuMoi -= giaoDichCu.soTien;
      } else {
        soDuMoi += giaoDichCu.soTien;
      }

      if (giaoDichMoi.loai == 'Thu nhập') {
        soDuMoi += giaoDichMoi.soTien;
      } else {
        soDuMoi -= giaoDichMoi.soTien;
      }
      soDuMoi = soDuMoi.clamp(0.0, double.infinity);

      setState(() {
        danhSachGiaoDich[index] = giaoDichMoi;
        soDu = soDuMoi;
      });

      final String giaoDichMoiJson =
          jsonEncode(danhSachGiaoDich.map((giaoDich) => giaoDich.toJson()).toList());
      await prefs.setString('${_currentUserPhone}_danh_sach_giao_dich', giaoDichMoiJson);
      await prefs.setDouble('${_currentUserPhone}_so_du', soDuMoi);
    } catch (e) {
      print('Lỗi khi cập nhật giao dịch: $e');
    }
  }

  Future<void> xoaHinhDaiDien() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.remove('${_currentUserPhone}_profileImage');
      setState(() {
        duongDanHinhDaiDien = null;
      });
    } catch (e) {
      print('Lỗi khi xóa hình đại diện: $e');
    }
  }

  void hienThiDialogChinhSua(BuildContext context, GiaoDich giaoDich, int index) {
    TextEditingController boDieuKhienSoTien =
        TextEditingController(text: giaoDich.soTien.toString());
    TextEditingController boDieuKhienMoTa =
        TextEditingController(text: giaoDich.moTa);
    TextEditingController boDieuKhienNgay = TextEditingController(
        text:
            '${giaoDich.ngayGio.day.toString().padLeft(2, '0')}/${giaoDich.ngayGio.month.toString().padLeft(2, '0')}/${giaoDich.ngayGio.year}');
    String loaiGiaoDich = giaoDich.loai;
    String nhomGiaoDich = giaoDich.nhom;
    DateTime ngayDuocChon = giaoDich.ngayGio;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> chonNgay() async {
              final DateTime? ngayChon = await showDatePicker(
                context: context,
                initialDate: ngayDuocChon,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF4A6AFF),
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black87,
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (ngayChon != null && ngayChon != ngayDuocChon) {
                setState(() {
                  ngayDuocChon = ngayChon;
                  boDieuKhienNgay.text =
                      '${ngayChon.day.toString().padLeft(2, '0')}/${ngayChon.month.toString().padLeft(2, '0')}/${ngayChon.year}';
                });
              }
            }

            List<String> danhSachNhomHienTai = loaiGiaoDich == 'Chi tiêu'
                ? danhSachNhomChiTieu
                : danhSachNhomThuNhap;

            if (!danhSachNhomHienTai.contains(nhomGiaoDich)) {
              nhomGiaoDich = danhSachNhomHienTai.first;
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A6AFF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFF4A6AFF),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Chỉnh sửa giao dịch',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Số tiền
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Số tiền',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: boDieuKhienSoTien,
                            decoration: InputDecoration(
                              hintText: 'Nhập số tiền',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFF4A6AFF), width: 2),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Mô tả
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mô tả',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: boDieuKhienMoTa,
                            decoration: InputDecoration(
                              hintText: 'Nhập mô tả',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFF4A6AFF), width: 2),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Loại giao dịch
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Loại giao dịch',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      loaiGiaoDich = 'Thu nhập';
                                      danhSachNhomHienTai = danhSachNhomThuNhap;
                                      nhomGiaoDich = danhSachNhomHienTai.contains('Khác')
                                          ? 'Khác'
                                          : danhSachNhomHienTai.first;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: loaiGiaoDich == 'Thu nhập'
                                          ? const Color(0xFF34C759)
                                          : const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: loaiGiaoDich == 'Thu nhập'
                                            ? const Color(0xFF34C759)
                                            : const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: Text(
                                      'Thu nhập',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: loaiGiaoDich == 'Thu nhập'
                                            ? Colors.white
                                            : const Color(0xFF6B7280),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      loaiGiaoDich = 'Chi tiêu';
                                      danhSachNhomHienTai = danhSachNhomChiTieu;
                                      nhomGiaoDich = danhSachNhomHienTai.contains('Khác')
                                          ? 'Khác'
                                          : danhSachNhomHienTai.first;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: loaiGiaoDich == 'Chi tiêu'
                                          ? const Color(0xFFFF2D55)
                                          : const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: loaiGiaoDich == 'Chi tiêu'
                                            ? const Color(0xFFFF2D55)
                                            : const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: Text(
                                      'Chi tiêu',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: loaiGiaoDich == 'Chi tiêu'
                                            ? Colors.white
                                            : const Color(0xFF6B7280),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Nhóm
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nhóm',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: nhomGiaoDich,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFF4A6AFF), width: 2),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            items: danhSachNhomHienTai
                                .map((nhom) => DropdownMenuItem(
                                      value: nhom,
                                      child: Text(nhom),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                nhomGiaoDich = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Ngày
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ngày',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: boDieuKhienNgay,
                            decoration: InputDecoration(
                              hintText: 'Chọn ngày',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFF4A6AFF), width: 2),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              suffixIcon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF6B7280)),
                            ),
                            readOnly: true,
                            onTap: chonNgay,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                              ),
                              child: const Text(
                                'Hủy',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final giaoDichMoi = GiaoDich(
                                  loai: loaiGiaoDich,
                                  soTien: double.tryParse(boDieuKhienSoTien.text) ?? 0.0,
                                  moTa: boDieuKhienMoTa.text,
                                  ngayGio: ngayDuocChon,
                                  nhom: nhomGiaoDich,
                                  ngay: '',
                                  tenKhoan: '',
                                );
                                capNhatGiaoDich(index, giaoDichMoi);
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A6AFF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Lưu',
                                style: TextStyle(
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
          },
        );
      },
    );
  }

  void khiAnVaoMuc(int chiSo) {
    setState(() {
      chiSoDuocChon = chiSo;
    });

    // Trigger page transition animation
    _pageAnimationController.reset();
    _pageAnimationController.forward();
  }

  void capNhatHinhDaiDien(String? newImagePath) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      if (newImagePath != null && File(newImagePath).existsSync()) {
        await prefs.setString('${_currentUserPhone}_profileImage', newImagePath);
        setState(() {
          duongDanHinhDaiDien = newImagePath;
        });
      } else {
        await prefs.remove('${_currentUserPhone}_profileImage');
        setState(() {
          duongDanHinhDaiDien = null;
        });
      }
    } catch (e) {
      print('Lỗi khi cập nhật hình đại diện: $e');
    }
  }

  void capNhatTen(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString('${_currentUserPhone}_ten', newName);
      setState(() {
        ten = newName;
      });
    } catch (e) {
      print('Lỗi khi cập nhật tên: $e');
    }
  }

  Future<void> capNhatSoDu(double newSoDu) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final soDuMoi = newSoDu.clamp(0.0, double.infinity);
      await prefs.setDouble('${_currentUserPhone}_so_du', soDuMoi);
      setState(() {
        soDu = soDuMoi;
      });
    } catch (e) {
      print('Lỗi khi cập nhật số dư: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ngayHienTai = DateTime.now();
    final thangHienTai = ngayHienTai.month;
    final namHienTai = ngayHienTai.year;

    final ketQuaHienTai = tinhTongTheoNhom(danhSachGiaoDich, thangHienTai, namHienTai);
    final chiTieuHienTai = ketQuaHienTai['Chi tiêu']!;
    final thuNhapHienTai = ketQuaHienTai['Thu nhập']!;

    final tongChiTieu = tinhTong(chiTieuHienTai);
    final tongThuNhap = tinhTong(thuNhapHienTai);

    final nhomChiTieuLonNhat = tongChiTieu > 0 ? timNhomLonNhat(chiTieuHienTai) : null;
    final nhomThuNhapLonNhat = tongThuNhap > 0 ? timNhomLonNhat(thuNhapHienTai) : null;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF4A6AFF), const Color(0xFF8E9EFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FadeTransition(
          opacity: _pageTransitionAnimation,
          child: IndexedStack(
            index: chiSoDuocChon,
            children: [
              TrangChuTab(
                ten: ten,
                soDu: soDu,
                duongDanHinhDaiDien: duongDanHinhDaiDien,
                danhSachGiaoDich: danhSachGiaoDich,
                tabHienTai: tabHienTai,
                tongChiTieu: tongChiTieu,
                tongThuNhap: tongThuNhap,
                onTabChanged: (index) {
                  setState(() {
                    tabHienTai = index;
                  });
                },
                onSoDuChanged: (newSoDu) {
                  capNhatSoDu(newSoDu);
                },
                onImageChange: (newImagePath) {
                  capNhatHinhDaiDien(newImagePath);
                },
                onMucTieuTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManHinhQuanLyMucTieu(
                        mucTieu: mucTieuTietKiem,
                        tongTienTietKiem: tongTienTietKiem,
                        soDu: soDu,
                        onMucTieuUpdated: (newMucTieu, _) {
                          setState(() {
                            mucTieuTietKiem = newMucTieu;
                          });
                          _saveMucTieu();
                        },
                      ),
                    ),
                  );
                  if (result != null && result is Map<String, dynamic>) {
                    setState(() {
                      mucTieuTietKiem = result['mucTieu'] ?? mucTieuTietKiem;
                      tongTienTietKiem = result['tongTienTietKiem'] ?? tongTienTietKiem;
                    });
                    _saveMucTieu();
                  }
                },
              ),
              GiaoDichTab(
                danhSachGiaoDich: danhSachGiaoDich,
                onThemGiaoDich: (giaoDichMoi) async {
                  final prefs = await SharedPreferences.getInstance();
                  try {
                    List<GiaoDich> updatedList = List.from(danhSachGiaoDich)..add(giaoDichMoi);
                    double soDuMoi = soDu;
                    if (giaoDichMoi.loai == 'Thu nhập') {
                      soDuMoi += giaoDichMoi.soTien;
                    } else {
                      soDuMoi -= giaoDichMoi.soTien;
                    }
                    soDuMoi = soDuMoi.clamp(0.0, double.infinity);
                    setState(() {
                      danhSachGiaoDich = updatedList;
                      soDu = soDuMoi;
                    });
                    await prefs.setString(
                        '${_currentUserPhone}_danh_sach_giao_dich',
                        jsonEncode(updatedList.map((giaoDich) => giaoDich.toJson()).toList()));
                    await prefs.setDouble('${_currentUserPhone}_so_du', soDuMoi);
                  } catch (e) {
                    print('Lỗi khi thêm giao dịch: $e');
                  }
                },
                onXoaGiaoDich: (index) => xoaGiaoDich(index),
                onEdit: (giaoDich, index) => hienThiDialogChinhSua(context, giaoDich, index),
                onDelete: (index) => xoaGiaoDich(index),
                onRefresh: () {
                  taiDanhSachGiaoDich();
                  layDuLieu();
                },
                danhSachKhoanSoDu: [],
              ),
              ThongKeTab(
                danhSachGiaoDich: danhSachGiaoDich,
                tongChiTieu: tongChiTieu,
                tongThuNhap: tongThuNhap,
                nhomChiTieuLonNhat: nhomChiTieuLonNhat,
                nhomThuNhapLonNhat: nhomThuNhapLonNhat,
                chiTieuHienTai: chiTieuHienTai,
                thuNhapHienTai: thuNhapHienTai,
                soDu: soDu,
              ),
              HoSoTab(
                ten: ten,
                soDienThoai: soDienThoai,
                soDu: soDu,
                duongDanHinhDaiDien: duongDanHinhDaiDien,
                onLogout: () async {
                  final prefs = await SharedPreferences.getInstance();
                  try {
                    await xoaHinhDaiDien();
                    await prefs.setBool('isLoggedIn', false);
                    await prefs.remove('currentUserPhone');
                    Navigator.pushReplacementNamed(context, '/dang_nhap');
                  } catch (e) {
                    print('Lỗi khi đăng xuất: $e');
                  }
                },
                onImageChange: (newImagePath) {
                  capNhatHinhDaiDien(newImagePath);
                },
                onNameChange: (newName) {
                  capNhatTen(newName);
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFF4A6AFF),
            unselectedItemColor: Colors.grey.shade500,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
            currentIndex: chiSoDuocChon > 1 ? chiSoDuocChon + 1 : chiSoDuocChon,
            onTap: (index) async {
              try {
                if (index == 2) {
                  _fabAnimationController.forward().then((_) => _fabAnimationController.reverse());
                  final result = await Navigator.pushNamed(context, '/them_giao_dich');
                  if (result != null && result is Map<String, dynamic>) {
                    final giaoDichMoi = GiaoDich(
                      loai: result['loai'] as String,
                      soTien: result['soTien'] as double,
                      moTa: result['moTa'] as String,
                      ngayGio: DateTime.now(),
                      nhom: result['nhom'] as String,
                      ngay: '',
                      tenKhoan: result['nguonKhoan'] as String,
                    );
                    final prefs = await SharedPreferences.getInstance();
                    List<GiaoDich> updatedList = List.from(danhSachGiaoDich)..add(giaoDichMoi);
                    double soDuMoi = soDu;
                    if (giaoDichMoi.loai == 'Thu nhập') {
                      soDuMoi += giaoDichMoi.soTien;
                    } else {
                      soDuMoi -= giaoDichMoi.soTien;
                    }
                    soDuMoi = soDuMoi.clamp(0.0, double.infinity);
                    setState(() {
                      danhSachGiaoDich = updatedList;
                      soDu = soDuMoi;
                    });
                    await prefs.setString(
                        '${_currentUserPhone}_danh_sach_giao_dich',
                        jsonEncode(updatedList.map((giaoDich) => giaoDich.toJson()).toList()));
                    await prefs.setDouble('${_currentUserPhone}_so_du', soDuMoi);
                    await _loadDanhSachNhom();
                    await _saveDanhSachNhom();
                  }
                  taiDanhSachGiaoDich();
                  layDuLieu();
                } else if (index > 2) {
                  khiAnVaoMuc(index - 1);
                } else {
                  khiAnVaoMuc(index);
                }
              } catch (e) {
                print('Lỗi khi điều hướng bottom navigation: $e');
              }
            },
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Trang chủ',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.swap_horizontal_circle_rounded),
                label: 'Giao dịch',
              ),
              BottomNavigationBarItem(
                icon: ScaleTransition(
                  scale: _fabScaleAnimation,
                  child: Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A6AFF), Color(0xFF8E9EFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
                label: '',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.pie_chart_rounded),
                label: 'Thống kê',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Hồ sơ',
              ),
            ],
          ),
        ),
      ),
    );
  }
}