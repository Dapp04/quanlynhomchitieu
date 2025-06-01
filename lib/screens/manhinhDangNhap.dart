// ignore_for_file: deprecated_member_use, file_names, library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:qlct/screens/manhinhDangKy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ManHinhDangNhap extends StatefulWidget {
  const ManHinhDangNhap({super.key});

  @override
  _ManHinhDangNhapState createState() => _ManHinhDangNhapState();
}

class _ManHinhDangNhapState extends State<ManHinhDangNhap> {
  final boDieuKhienSoDienThoai = TextEditingController();
  final boDieuKhienMatKhau = TextEditingController();
  bool anMatKhau = true;
  bool coThongTinLuu = false;
  bool hienThiGoiY = false;
  String? soDienThoaiLuu;
  String? matKhauLuu;
  List<Map<String, String>> danhSachTaiKhoan = [];

  @override
  void initState() {
    super.initState();
    kiemTraThongTinLuu();
    _loadDanhSachTaiKhoan();
    boDieuKhienSoDienThoai.addListener(kiemTraSoDienThoai);
  }

  Future<void> kiemTraThongTinLuu() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      bool luuDangNhap = prefs.getBool('luu_dang_nhap') ?? false;
      if (luuDangNhap) {
        setState(() {
          coThongTinLuu = true;
          soDienThoaiLuu = prefs.getString('luu_so_dien_thoai');
          matKhauLuu = prefs.getString('luu_mat_khau');
        });
      }
    } catch (e) {
      print('Lỗi khi kiểm tra thông tin lưu: $e');
    }
  }

  Future<void> _loadDanhSachTaiKhoan() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      String? danhSachTaiKhoanJson = prefs.getString('danh_sach_tai_khoan');
      if (danhSachTaiKhoanJson != null) {
        setState(() {
          danhSachTaiKhoan = (jsonDecode(danhSachTaiKhoanJson) as List)
              .map((item) => Map<String, String>.from(item))
              .toList();
        });
      }
    } catch (e) {
      print('Lỗi khi tải danh sách tài khoản: $e');
      setState(() {
        danhSachTaiKhoan = [];
      });
    }
  }

  void kiemTraSoDienThoai() {
    setState(() {
      String input = boDieuKhienSoDienThoai.text.trim();
      hienThiGoiY = input.isNotEmpty &&
          danhSachTaiKhoan.any((tk) => tk['soDienThoai']!.startsWith(input));
    });
  }

  Future<void> dangNhap(BuildContext context) async {
    if (boDieuKhienSoDienThoai.text.trim().isEmpty ||
        boDieuKhienMatKhau.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng không để trống')),
      );
      return;
    }

    if (boDieuKhienSoDienThoai.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số điện thoại phải đủ 10 số')),
      );
      return;
    }

    if (boDieuKhienMatKhau.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu phải từ 8 ký tự trở lên')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    List<Map<String, String>> danhSachTaiKhoan = [];
    String? danhSachTaiKhoanJson = prefs.getString('danh_sach_tai_khoan');
    if (danhSachTaiKhoanJson != null) {
      danhSachTaiKhoan = (jsonDecode(danhSachTaiKhoanJson) as List)
          .map((item) => Map<String, String>.from(item))
          .toList();
    }

    String soDienThoai = boDieuKhienSoDienThoai.text.trim();
    String matKhau = boDieuKhienMatKhau.text;

    var taiKhoan = danhSachTaiKhoan.firstWhere(
      (tk) => tk['soDienThoai'] == soDienThoai && tk['matKhau'] == matKhau,
      orElse: () => {},
    );

    if (taiKhoan.isNotEmpty) {
      await prefs.setString('currentUserPhone', soDienThoai);
      await prefs.setBool('isLoggedIn', true);
      Navigator.pushReplacementNamed(context, '/trang_chu');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số điện thoại hoặc mật khẩu không đúng')),
      );
    }
  }

  void dienThongTinDaLuu(String soDienThoai) {
    var taiKhoan = danhSachTaiKhoan.firstWhere(
      (tk) => tk['soDienThoai'] == soDienThoai,
      orElse: () => {'soDienThoai': soDienThoai, 'matKhau': ''},
    );
    setState(() {
      boDieuKhienSoDienThoai.text = soDienThoai;
      boDieuKhienMatKhau.text = taiKhoan['matKhau'] ?? '';
      hienThiGoiY = false;
    });
  }

  @override
  void dispose() {
    boDieuKhienSoDienThoai.removeListener(kiemTraSoDienThoai);
    boDieuKhienSoDienThoai.dispose();
    boDieuKhienMatKhau.dispose();
    super.dispose();
  }

  Route _createFadeSlideRoute(RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) {
        if (settings.name == '/dang_ky') {
          return ManHinhDangKy();
        }
        return const SizedBox.shrink();
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var slideAnimation = animation.drive(tween);

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFAEDCCE), Color(0xFF5DADE2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - MediaQuery.of(context).padding.top,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Lottie.asset(
                      'assets/animations/anhdangnhap.json',
                      width: 350,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: boDieuKhienSoDienThoai,
                            decoration: InputDecoration(
                              labelText: 'Số điện thoại',
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              prefixIcon: const Icon(Icons.phone, color: Colors.teal),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          if (hienThiGoiY)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Column(
                                children: danhSachTaiKhoan
                                    .where((tk) => tk['soDienThoai']!
                                        .startsWith(boDieuKhienSoDienThoai.text.trim()))
                                    .map((tk) => GestureDetector(
                                          onTap: () => dienThongTinDaLuu(tk['soDienThoai']!),
                                          child: Container(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 20),
                                            decoration: BoxDecoration(
                                              color: Colors.teal.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: Colors.teal),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.account_circle,
                                                    color: Colors.teal),
                                                const SizedBox(width: 10),
                                                Text(
                                                  tk['soDienThoai']!,
                                                  style: const TextStyle(
                                                      color: Colors.teal,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: boDieuKhienMatKhau,
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              prefixIcon: const Icon(Icons.lock, color: Colors.teal),
                              suffixIcon: IconButton(
                                icon: Icon(
                                    anMatKhau ? Icons.visibility_off : Icons.visibility),
                                onPressed: () {
                                  setState(() {
                                    anMatKhau = !anMatKhau;
                                  });
                                },
                              ),
                            ),
                            obscureText: anMatKhau,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 40),
                              elevation: 5,
                            ),
                            onPressed: () => dangNhap(context),
                            child: const Text(
                              'Đăng nhập',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                _createFadeSlideRoute(const RouteSettings(name: '/dang_ky')),
                              );
                            },
                            child: const Text(
                              'Chưa có tài khoản? Đăng ký',
                              style: TextStyle(color: Colors.teal),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}