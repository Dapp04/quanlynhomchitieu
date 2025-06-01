// ignore_for_file: deprecated_member_use, unused_element, library_private_types_in_public_api, use_build_context_synchronously, avoid_print, unnecessary_const

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HoSoTab extends StatefulWidget {
  final String ten;
  final String soDienThoai;
  final double soDu;
  final String? duongDanHinhDaiDien;
  final VoidCallback onLogout;
  final Function(String?) onImageChange;
  final Function(String) onNameChange;

  const HoSoTab({
    super.key,
    required this.ten,
    required this.soDienThoai,
    required this.soDu,
    required this.duongDanHinhDaiDien,
    required this.onLogout,
    required this.onImageChange,
    required this.onNameChange,
  });

  @override
  _HoSoTabState createState() => _HoSoTabState();
}

class _HoSoTabState extends State<HoSoTab> {
  String _selectedTheme = 'Light Teal';
  List<Map<String, dynamic>> _themes = [];
  bool _isLoading = true;
  String _currentUserPhone = '';

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
        // Load profile image for the current user
        String? storedImagePath = prefs.getString('${_currentUserPhone}_profileImage');
        if (storedImagePath != null && File(storedImagePath).existsSync()) {
          widget.onImageChange(storedImagePath);
        } else {
          widget.onImageChange(null); // Clear if no valid image
        }
        _loadTheme();
      });
    } catch (e) {
      print('Lỗi khi tải thông tin người dùng: $e');
      setState(() {
        _currentUserPhone = '';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
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
      _isLoading = false;
    });
  }

  Future<void> _saveTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_currentUserPhone}_selectedTheme', themeName);
    setState(() {
      _selectedTheme = themeName;
    });
    _applyThemeToApp(themeName);
  }

  void _applyThemeToApp(String themeName) {
    // Placeholder để đồng bộ theme với các tab khác
  }

  Future<void> _clearProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_currentUserPhone}_profileImage');
    widget.onImageChange(null);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không', style: TextStyle(color: Colors.grey)),
          ),
          GestureDetector(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await _clearProfileImage(); // Clear profile image before logout
              await prefs.remove('currentUserPhone'); // Clear current user
              Navigator.pop(context);
              widget.onLogout();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF5350), Color(0xFFE53935)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                'Có',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${_currentUserPhone}_profileImage', image.path);
      widget.onImageChange(image.path);
    }
  }

  void _showEditDialog(BuildContext context) {
    String newName = widget.ten;
    TextEditingController nameController = TextEditingController(text: widget.ten);
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Chỉnh sửa hồ sơ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: currentTheme['primaryColor'],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _pickImage(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF40C4FF), const Color(0xFF81D4FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text(
                  'Chọn hình mới',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Tên mới',
                labelStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(
                  Icons.person,
                  color: Color(0xFF40C4FF),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF40C4FF), width: 2),
                ),
              ),
              onChanged: (value) {
                newName = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          GestureDetector(
            onTap: () async {
              if (newName.isNotEmpty) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('${_currentUserPhone}_ten', newName);
                widget.onNameChange(newName);
              }
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF40C4FF), Color(0xFF81D4FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                'Lưu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAccountInfo(BuildContext context) {
    final TextEditingController tenController = TextEditingController(text: widget.ten);
    final TextEditingController soDienThoaiController = TextEditingController(text: widget.soDienThoai);
    final TextEditingController soDuController = TextEditingController(
      text: '${widget.soDu.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )} VNĐ',
    );
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

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông tin tài khoản',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: currentTheme['primaryColor'],
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField('Tên', tenController),
              _buildTextField('Số điện thoại', soDienThoaiController),
              _buildTextField('Số dư', soDuController, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF40C4FF), Color(0xFF81D4FA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Đóng',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    String chuCaiDau = widget.ten.isNotEmpty ? widget.ten[0].toUpperCase() : 'U';
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

    return Container(
      color: const Color(0xFFF5F7FA),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF40C4FF), Color(0xFF81D4FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 38,
                            backgroundColor: Colors.grey[300],
                            child: widget.duongDanHinhDaiDien != null &&
                                    File(widget.duongDanHinhDaiDien!).existsSync()
                                ? ClipOval(
                                    child: Image.file(
                                      File(widget.duongDanHinhDaiDien!),
                                      width: 76,
                                      height: 76,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Text(
                                        chuCaiDau,
                                        style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : Text(
                                    chuCaiDau,
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tên người dùng',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            widget.ten,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _showEditDialog(context),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white70,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thành viên prenmium',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildListItem(
                    context: context,
                    icon: Icons.person,
                    title: 'Thông tin tài khoản',
                    onTap: () => _showAccountInfo(context),
                  ),
                  const SizedBox(height: 16),
                  _buildListItem(
                    context: context,
                    icon: Icons.lock,
                    title: 'Đổi mật khẩu',
                    onTap: () => Navigator.pushNamed(context, '/doi_mat_khau'),
                  ),
                  const SizedBox(height: 16),
                  _buildListItem(
                    context: context,
                    icon: Icons.palette,
                    title: 'Chọn chủ đề',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          title: Text(
                            'Chọn chủ đề',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: currentTheme['primaryColor'],
                            ),
                          ),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: DropdownButton<String>(
                              value: _selectedTheme,
                              items: _themes.map((theme) {
                                return DropdownMenuItem<String>(
                                  value: theme['name'],
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: theme['gradientColors'],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(theme['name']),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _saveTheme(value);
                                  Navigator.pop(context);
                                }
                              },
                              style: const TextStyle(
                                color: Color(0xFF212121),
                                fontSize: 14,
                              ),
                              dropdownColor: Colors.white,
                              underline: const SizedBox(),
                              isExpanded: true,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Đóng', style: TextStyle(color: Colors.grey)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  _buildListItem(
                    context: context,
                    icon: Icons.logout,
                    title: 'Đăng xuất',
                    onTap: () => _showLogoutDialog(context),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
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

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: title == 'Đăng xuất' ? const Color(0xFFEF5350) : currentTheme['primaryColor'],
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: title == 'Đăng xuất' ? const Color(0xFFEF5350) : const Color(0xFF212121),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF40C4FF), width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
        ),
        enabled: false,
      ),
    );
  }
}