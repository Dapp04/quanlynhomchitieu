// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/manhinhKhoiDong.dart';
import 'screens/manhinhDangNhap.dart';
import 'screens/manhinhDangKy.dart';
import 'screens/manhinhTrangChu.dart';
import 'screens/manhinhThemGiaoDich.dart';
import 'screens/manhinhDoiMatKhau.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }

  await NotificationService.initialize();

  runApp(const UngDungQuanLyTaiChinh());
}

class UngDungQuanLyTaiChinh extends StatelessWidget {
  const UngDungQuanLyTaiChinh({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng Quản lý Tài chính',
      theme: ThemeData(primarySwatch: Colors.teal),
      debugShowCheckedModeBanner: false,
      initialRoute: '/khoi_dong',
      routes: {
        '/khoi_dong': (context) => const ManHinhKhoiDong(),
        '/dang_ky': (context) => const ManHinhDangKy(),
        '/dang_nhap': (context) => const ManHinhDangNhap(),
        '/trang_chu': (context) => const ManHinhTrangChu(),
        '/them_giao_dich': (context) => const ManHinhThemGiaoDich(),
        '/doi_mat_khau': (context) => const ManHinhDoiMatKhau(),
      },
    );
  }
}