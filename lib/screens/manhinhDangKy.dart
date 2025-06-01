// ignore_for_file: use_build_context_synchronously, file_names, deprecated_member_use, avoid_print, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:qlct/screens/manhinhDangNhap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ManHinhDangKy extends StatefulWidget {
  const ManHinhDangKy({super.key});

  @override
  _ManHinhDangKyState createState() => _ManHinhDangKyState();
}

class _ManHinhDangKyState extends State<ManHinhDangKy> {
  final boDieuKhienTen = TextEditingController();
  final boDieuKhienSoDienThoai = TextEditingController();
  final boDieuKhienMatKhau = TextEditingController();
  final boDieuKhienXacNhanMatKhau = TextEditingController();
  bool hienThiGoiY = false;
  List<Map<String, String>> danhSachTaiKhoan = [];

  @override
  void initState() {
    super.initState();
    _loadDanhSachTaiKhoan();
    boDieuKhienSoDienThoai.addListener(kiemTraSoDienThoai);
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

  void dienThongTinDaLuu(String soDienThoai) {
    setState(() {
      boDieuKhienSoDienThoai.text = soDienThoai;
      hienThiGoiY = false;
    });
  }

  Future<void> dangKy(BuildContext context) async {
    if (boDieuKhienTen.text.trim().isEmpty ||
        boDieuKhienSoDienThoai.text.trim().isEmpty ||
        boDieuKhienMatKhau.text.trim().isEmpty ||
        boDieuKhienXacNhanMatKhau.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng không để trống')),
      );
      return;
    }

    if (boDieuKhienMatKhau.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu phải từ 8 ký tự trở lên')),
      );
      return;
    }

    if (boDieuKhienSoDienThoai.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số điện thoại phải đủ 10 số')),
      );
      return;
    }

    if (boDieuKhienMatKhau.text != boDieuKhienXacNhanMatKhau.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu không khớp')),
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
    String ten = boDieuKhienTen.text.trim();

    bool daTonTai = danhSachTaiKhoan.any((tk) => tk['soDienThoai'] == soDienThoai);
    if (daTonTai) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số điện thoại đã được đăng ký!')),
      );
      return;
    }

    danhSachTaiKhoan.add({
      'ten': ten,
      'soDienThoai': soDienThoai,
      'matKhau': matKhau,
    });

    await prefs.setString('danh_sach_tai_khoan', jsonEncode(danhSachTaiKhoan));
    await prefs.setString('${soDienThoai}_ten', ten);
    await prefs.setDouble('${soDienThoai}_soDu', 0.0);
    await prefs.setString('${soDienThoai}_danh_sach_giao_dich', jsonEncode([]));

    bool? luuMatKhau = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lưu thông tin đăng nhập'),
        content: const Text('Bạn có muốn lưu thông tin đăng nhập để đăng nhập dễ hơn không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không lưu'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lưu', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );

    if (luuMatKhau == true) {
      await prefs.setBool('luu_dang_nhap', true);
      await prefs.setString('luu_so_dien_thoai', boDieuKhienSoDienThoai.text);
      await prefs.setString('luu_mat_khau', boDieuKhienMatKhau.text);
    } else {
      await prefs.setBool('luu_dang_nhap', false);
    }

    Navigator.pushReplacement(
      context,
      _createFadeSlideRoute(const RouteSettings(name: '/dang_nhap')),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đăng ký thành công! Vui lòng đăng nhập.')),
    );
  }

  Route _createFadeSlideRoute(RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) {
        if (settings.name == '/dang_nhap') {
          return const ManHinhDangNhap();
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
  void dispose() {
    boDieuKhienTen.dispose();
    boDieuKhienSoDienThoai.removeListener(kiemTraSoDienThoai);
    boDieuKhienSoDienThoai.dispose();
    boDieuKhienMatKhau.dispose();
    boDieuKhienXacNhanMatKhau.dispose();
    super.dispose();
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
                      'assets/animations/anhdangky.json',
                      width: 350,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: boDieuKhienTen,
                            decoration: const InputDecoration(
                              labelText: 'Nhập tên của bạn',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              prefixIcon: Icon(Icons.person, color: Colors.teal),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: boDieuKhienSoDienThoai,
                            decoration: const InputDecoration(
                              labelText: 'Nhập số điện thoại của bạn',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              prefixIcon: Icon(Icons.phone, color: Colors.teal),
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
                            decoration: const InputDecoration(
                              labelText: 'Nhập mật khẩu của bạn',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              prefixIcon: Icon(Icons.lock, color: Colors.teal),
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: boDieuKhienXacNhanMatKhau,
                            decoration: const InputDecoration(
                              labelText: 'Xác nhận mật khẩu',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              prefixIcon: Icon(Icons.lock, color: Colors.teal),
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 40),
                              elevation: 5,
                            ),
                            onPressed: () => dangKy(context),
                            child: const Text(
                              'Đăng ký',
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
                                _createFadeSlideRoute(const RouteSettings(name: '/dang_nhap')),
                              );
                            },
                            child: const Text(
                              'Đã có tài khoản? Đăng nhập',
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