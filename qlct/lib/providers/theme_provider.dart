import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  String _selectedTheme = 'Light Teal';
  final List<Map<String, dynamic>> _themes = [
    {'name': 'Light Teal', 'gradientColors': [Color(0xFFAEDCCE), Color(0xFF5DADE2)], 'primaryColor': Colors.teal},
    {'name': 'Dark Blue', 'gradientColors': [Color(0xFF2C3E50), Color(0xFF3498DB)], 'primaryColor': Color(0xFF3498DB)},
    {'name': 'Purple', 'gradientColors': [Color(0xFF6B48FF), Color(0x00ab6aff)], 'primaryColor': Color(0xFF6B48FF)},
    {'name': 'Orange', 'gradientColors': [Color(0xFFFFA726), Color(0xFFFF7043)], 'primaryColor': Color(0xFFFFA726)},
  ];

  String get selectedTheme => _selectedTheme;
  Map<String, dynamic> get currentTheme => _themes.firstWhere((t) => t['name'] == _selectedTheme);

  void setTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTheme', themeName);
    _selectedTheme = themeName;
    notifyListeners();
  }

  void loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedTheme = prefs.getString('selectedTheme') ?? 'Light Teal';
    notifyListeners();
  }
}