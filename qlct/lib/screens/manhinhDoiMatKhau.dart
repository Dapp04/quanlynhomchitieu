// ignore_for_file: file_names, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManHinhDoiMatKhau extends StatefulWidget {
  const ManHinhDoiMatKhau({super.key});

  @override
  State<ManHinhDoiMatKhau> createState() => _ManHinhDoiMatKhauState();
}

class _ManHinhDoiMatKhauState extends State<ManHinhDoiMatKhau> {
  final TextEditingController _matKhauCuController = TextEditingController();
  final TextEditingController _matKhauMoiController = TextEditingController();
  final TextEditingController _xacNhanMatKhauController = TextEditingController();
  bool _obscureMatKhauCu = true;
  bool _obscureMatKhauMoi = true;
  bool _obscureXacNhanMatKhau = true;

  Future<void> _doiMatKhau() async {
    final prefs = await SharedPreferences.getInstance();
    final matKhauHienTai = prefs.getString('mat_khau') ?? '';

    if (_matKhauCuController.text != matKhauHienTai) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu cũ không đúng')),
      );
      return;
    }

    if (_matKhauMoiController.text != _xacNhanMatKhauController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu mới và xác nhận không khớp')),
      );
      return;
    }

    if (_matKhauMoiController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu mới phải có ít nhất 6 ký tự')),
      );
      return;
    }

    await prefs.setString('mat_khau', _matKhauMoiController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đổi mật khẩu thành công')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Đổi mật khẩu',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF6366F1),
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _matKhauCuController,
                    obscureText: _obscureMatKhauCu,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu cũ',
                      labelStyle: const TextStyle(
                        fontFamily: 'Roboto',
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF6366F1),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureMatKhauCu ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureMatKhauCu = !_obscureMatKhauCu;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: const Color(0xFFE0E7FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _matKhauMoiController,
                    obscureText: _obscureMatKhauMoi,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu mới',
                      labelStyle: const TextStyle(
                        fontFamily: 'Roboto',
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF6366F1),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureMatKhauMoi ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureMatKhauMoi = !_obscureMatKhauMoi;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: const Color(0xFFE0E7FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _xacNhanMatKhauController,
                    obscureText: _obscureXacNhanMatKhau,
                    decoration: InputDecoration(
                      labelText: 'Xác nhận mật khẩu mới',
                      labelStyle: const TextStyle(
                        fontFamily: 'Roboto',
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF6366F1),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureXacNhanMatKhau ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureXacNhanMatKhau = !_obscureXacNhanMatKhau;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: const Color(0xFFE0E7FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Hủy',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: Colors.black54,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _doiMatKhau,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Xác nhận',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: Colors.white,
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
        ),
      ),
    );
  }
}