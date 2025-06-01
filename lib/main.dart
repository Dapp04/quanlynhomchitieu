import 'package:flutter/material.dart';
import 'screens/manhinhKhoiDong.dart';
import 'screens/manhinhDangNhap.dart';
import 'screens/manhinhDangKy.dart';
import 'screens/manhinhTrangChu.dart';
import 'screens/manhinhThemGiaoDich.dart';
import 'screens/manhinhDoiMatKhau.dart';
import 'services/notification_service.dart';

void main() async {
  // Đảm bảo Flutter binding được khởi tạo trước khi gọi các hàm bất đồng bộ
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo dịch vụ thông báo
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
        '/dang_ky': (context) => ManHinhDangKy(),
        '/dang_nhap': (context) => ManHinhDangNhap(),
        '/trang_chu': (context) => const ManHinhTrangChu(),
        '/them_giao_dich': (context) => const ManHinhThemGiaoDich(),
        '/doi_mat_khau': (context) => const ManHinhDoiMatKhau(),
      },
    );
  }
}