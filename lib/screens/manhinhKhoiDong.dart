// ignore_for_file: use_build_context_synchronously, file_names

import 'package:flutter/material.dart';
import 'package:qlct/screens/manhinhDangKy.dart';
import 'package:qlct/screens/manhinhDangNhap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';



class ManHinhKhoiDong extends StatefulWidget {
  const ManHinhKhoiDong({super.key});

  @override
  TrangThaiManHinhKhoiDong createState() => TrangThaiManHinhKhoiDong();
}

class TrangThaiManHinhKhoiDong extends State<ManHinhKhoiDong> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Lottie.asset(
                  'assets/animations/anhkhoidong.json',
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                  repeat: true,
                  animate: true,
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                'Quản lý nhóm chi tiêu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              const Text(
                'Phân phối thu nhập và chi tiêu hợp lý.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  ),
                 onPressed: () async {
  final prefs = await SharedPreferences.getInstance();
  final soDienThoai = prefs.getString('so_dien_thoai');
  final nextRoute = (soDienThoai == null) ? '/dang_ky' : '/dang_nhap';

  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          _getNextScreen(nextRoute),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const beginOffset = Offset(0, 0.1); // nhẹ nhàng từ dưới lên
        const endOffset = Offset.zero;
        final tween = Tween(begin: beginOffset, end: endOffset).chain(CurveTween(curve: Curves.easeOut));

        final fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
    ),
  );
},

                  child: const Text(
                    'Tiếp theo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getNextScreen(String route) {
    switch (route) {
      case '/dang_ky':
        return ManHinhDangKy();
      case '/dang_nhap':
        return const ManHinhDangNhap();
      default:
        return ManHinhDangKy(); // Default screen if no match found
    }
  }
}