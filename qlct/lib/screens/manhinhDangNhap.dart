// ignore_for_file: deprecated_member_use, file_names, library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:qlct/screens/manhinhDangKy.dart';
import 'package:qlct/services/data_backup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';

class ManHinhDangNhap extends StatefulWidget {
  const ManHinhDangNhap({super.key});

  @override
  _ManHinhDangNhapState createState() => _ManHinhDangNhapState();
}

class _ManHinhDangNhapState extends State<ManHinhDangNhap> with SingleTickerProviderStateMixin {
  final boDieuKhienSoDienThoai = TextEditingController();
  final boDieuKhienMatKhau = TextEditingController();
  bool anMatKhau = true;
  bool coThongTinLuu = false;
  bool hienThiGoiY = false;
  String? soDienThoaiLuu;
  String? matKhauLuu;
  List<Map<String, String>> danhSachTaiKhoan = [];
  late AnimationController _lottieController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DataBackupService _backupService = DataBackupService();

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _lottieController, curve: Curves.easeInOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _lottieController, curve: Curves.easeInOut));
    _lottieController.forward();
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
    print('Attempting login with phone: ${boDieuKhienSoDienThoai.text}');
    if (boDieuKhienSoDienThoai.text.trim().isEmpty || boDieuKhienMatKhau.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng không để trống')));
      }
      print('Login failed: Empty fields');
      return;
    }

    if (boDieuKhienSoDienThoai.text.length != 10) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Số điện thoại phải đủ 10 số')));
      }
      print('Login failed: Invalid phone length');
      return;
    }

    if (boDieuKhienMatKhau.text.length < 8) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu phải từ 8 ký tự trở lên')));
      }
      print('Login failed: Invalid password length');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    List<Map<String, String>> danhSachTaiKhoan = [];
    String? danhSachTaiKhoanJson = prefs.getString('danh_sach_tai_khoan');
    if (danhSachTaiKhoanJson != null) {
      danhSachTaiKhoan = (jsonDecode(danhSachTaiKhoanJson) as List)
          .map((item) => Map<String, String>.from(item))
          .toList();
      print('Loaded accounts: $danhSachTaiKhoan');
    } else {
      print('No account data found in SharedPreferences');
    }

    String soDienThoai = boDieuKhienSoDienThoai.text.trim();
    String matKhau = boDieuKhienMatKhau.text;

    var taiKhoan = danhSachTaiKhoan.firstWhere(
      (tk) => tk['soDienThoai'] == soDienThoai && tk['matKhau'] == matKhau,
      orElse: () => {},
    );

    if (taiKhoan.isNotEmpty) {
      print('Login successful for $soDienThoai');
      await prefs.setString('currentUserPhone', soDienThoai);
      await prefs.setBool('isLoggedIn', true);

      try {
        await _backupService.restoreData(soDienThoai);
        print('Restore completed for $soDienThoai');
      } catch (e) {
        print('Restore error (non-critical): $e');
      }

      try {
        await _backupService.backupData(soDienThoai);
        print('Backup completed for $soDienThoai');
      } catch (e) {
        print('Backup error (non-critical): $e');
      }

      if (mounted) {
        print('Navigating to /trang_chu');
        try {
          Navigator.pushReplacementNamed(context, '/trang_chu');
        } catch (e) {
          print('Navigation error: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi điều hướng: $e')),
          );
        }
      } else {
        print('Widget is not mounted, skipping navigation');
      }
    } else {
      print('Login failed: No matching account for $soDienThoai');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Số điện thoại hoặc mật khẩu không đúng')));
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    print('Attempting Google Sign-In');
    try {
      String? locale = PlatformDispatcher.instance.locale.languageCode;
      locale = locale;
      print('Using locale: $locale');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign-In cancelled by user');
        return;
      }

      print('Google Sign-In success, getting credentials');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.setLanguageCode(locale);
      print('Locale set for Firebase: $locale');

      print('Authenticating with Firebase');
      final UserCredential userCredential;
      try {
        userCredential = await _auth.signInWithCredential(credential);
        print('Firebase sign-in result: ${userCredential.user?.email}');
      } catch (e) {
        print('Firebase authentication error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Firebase authentication failed: $e')),
          );
        }
        return;
      }

      final User? user = userCredential.user;

      if (user != null) {
        print('Firebase authentication success for user: ${user.email}');
        final prefs = await SharedPreferences.getInstance();
        String userId = user.phoneNumber ?? user.email!.replaceAll('@gmail.com', '');
        await prefs.setString('currentUserPhone', userId);
        await prefs.setString('${userId}_ten', user.displayName ?? 'User');
        await prefs.setDouble('${userId}_soDu', 0.0);
        await prefs.setString('${userId}_danh_sach_giao_dich', jsonEncode([]));
        await prefs.setBool('isLoggedIn', true);

        try {
          await _backupService.restoreData(userId);
          print('Restore completed for $userId');
        } catch (e) {
          print('Restore error (non-critical): $e');
        }

        try {
          await _backupService.backupData(userId);
          print('Backup completed for $userId');
        } catch (e) {
          print('Backup error (non-critical): $e');
        }

        print('Navigating to /trang_chu');
        try {
          await Future.delayed(Duration.zero); // Ensure UI is ready
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/trang_chu');
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng nhập Google thành công!')));
          } else {
            print('Widget not mounted, using global navigation');
            Navigator.of(context, rootNavigator: true).pushReplacementNamed('/trang_chu');
          }
        } catch (e) {
          print('Navigation error: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi điều hướng: $e')),
            );
          }
        }
      } else {
        print('No user object returned from Firebase');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể lấy thông tin người dùng.')));
        }
      }
    } catch (e) {
      print('Google Sign-In error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng nhập Google thất bại. Vui lòng thử lại!')));
      }
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
    _lottieController.dispose();
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
          return const ManHinhDangKy();
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
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - MediaQuery.of(context).padding.top,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _lottieController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Lottie.asset(
                            'assets/animations/anhdangnhap.json',
                            width: 350,
                            height: 250,
                            fit: BoxFit.cover,
                            controller: _lottieController,
                            onLoaded: (composition) {
                              _lottieController.duration = composition.duration;
                              _lottieController.forward(from: 0.0);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                              fontFamily: 'Roboto',
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                            ),
                            prefixIcon: const Icon(
                              Icons.phone,
                              color: Color(0xFF6366F1),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFE0E7FF),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        if (hienThiGoiY)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Column(
                              children: danhSachTaiKhoan
                                  .where((tk) => tk['soDienThoai']!.startsWith(boDieuKhienSoDienThoai.text.trim()))
                                  .map((tk) => GestureDetector(
                                        onTap: () => dienThongTinDaLuu(tk['soDienThoai']!),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFF6366F1)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.03),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.account_circle, color: Color(0xFF6366F1)),
                                              const SizedBox(width: 10),
                                              Text(
                                                tk['soDienThoai']!,
                                                style: const TextStyle(
                                                  fontFamily: 'Roboto',
                                                  color: Color(0xFF6366F1),
                                                  fontWeight: FontWeight.w500,
                                                ),
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
                              fontFamily: 'Roboto',
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                            ),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Color(0xFF6366F1),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                anMatKhau ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  anMatKhau = !anMatKhau;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: const Color(0xFFE0E7FF),
                          ),
                          obscureText: anMatKhau,
                        ),
                        const SizedBox(height: 20),
                        AnimatedBuilder(
                          animation: CurvedAnimation(parent: _lottieController, curve: Curves.easeInOut),
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (_lottieController.value * 0.05),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                                  elevation: 4,
                                ),
                                onPressed: () => dangNhap(context),
                                child: const Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Hoặc đăng nhập bằng ',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: _signInWithGoogle,
                              child: const Text(
                                'Google',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  color: Color(0xFF6366F1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: Colors.grey,
                              fontSize: 14,
                            ),
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
    );
  }
}