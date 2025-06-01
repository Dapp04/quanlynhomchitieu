// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print, file_names

import 'package:flutter/material.dart';
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

class TrangThaiManHinhTrangChu extends State<ManHinhTrangChu> {
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

  // Mục tiêu
  double mucTieuTietKiem = 1000000.0;
  double mucTieuChiTieuToiDa = 500000.0;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserPhone();
  }

  Future<void> _loadCurrentUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      setState(() {
        _currentUserPhone = prefs.getString('currentUserPhone') ?? '';
        _loadDanhSachNhom();
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

  Future<void> _saveDanhSachNhom() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setStringList('${_currentUserPhone}_danh_sach_nhom_chi_tieu', danhSachNhomChiTieu);
      await prefs.setStringList('${_currentUserPhone}_danh_sach_nhom_thu_nhap', danhSachNhomThuNhap);
    } catch (e) {
      print('Lỗi khi lưu danh sách nhóm: $e');
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
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> chonNgay() async {
              final DateTime? ngayChon = await showDatePicker(
                context: context,
                initialDate: ngayDuocChon,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
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

            return AlertDialog(
              title: const Text('Chỉnh sửa giao dịch'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: boDieuKhienSoTien,
                      decoration: const InputDecoration(
                        labelText: 'Số tiền',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: boDieuKhienMoTa,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                loaiGiaoDich == 'Thu nhập' ? Colors.green : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              loaiGiaoDich = 'Thu nhập';
                              danhSachNhomHienTai = danhSachNhomThuNhap;
                              nhomGiaoDich = danhSachNhomHienTai.contains('Khác')
                                  ? 'Khác'
                                  : danhSachNhomHienTai.first;
                            });
                          },
                          child: const Text('Thu nhập'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                loaiGiaoDich == 'Chi tiêu' ? Colors.red : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              loaiGiaoDich = 'Chi tiêu';
                              danhSachNhomHienTai = danhSachNhomChiTieu;
                              nhomGiaoDich = danhSachNhomHienTai.contains('Khác')
                                  ? 'Khác'
                                  : danhSachNhomHienTai.first;
                            });
                          },
                          child: const Text('Chi tiêu'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: nhomGiaoDich,
                      decoration: const InputDecoration(
                        labelText: 'Chọn nhóm',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: boDieuKhienNgay,
                      decoration: const InputDecoration(
                        labelText: 'Chọn ngày',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: chonNgay,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                TextButton(
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
                  child: const Text('Lưu', style: TextStyle(color: Colors.teal)),
                ),
              ],
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: IndexedStack(
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
                await xoaHinhDaiDien(); // Clear profile image before logout
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFAB47BC),
        unselectedItemColor: const Color(0xFF40C4FF),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        currentIndex: chiSoDuocChon > 1 ? chiSoDuocChon + 1 : chiSoDuocChon,
        onTap: (index) async {
          try {
            if (index == 2) {
              final result = await Navigator.pushNamed(context, '/them_giao_dich');
              if (result != null && result is Map<String, dynamic>) {
                final giaoDichMoi = GiaoDich(
                  loai: result['loai'] as String,
                  soTien: result['soTien'] as double,
                  moTa: result['moTa'] as String,
                  ngayGio: DateTime.now(),
                  nhom: result['nhom'] as String,
                  ngay: '',
                  tenKhoan: result['nguonKhoan'] as String, // Sử dụng giá trị nguồn khoản
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
            icon: Container(
              height: 56,
              width: 56,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF40C4FF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white),
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
    );
  }
}