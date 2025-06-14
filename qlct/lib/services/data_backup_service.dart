// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataBackupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> backupData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print('Backing up data for user: $userId');
      Map<String, dynamic> dataToBackup = {
        'danh_sach_tai_khoan': prefs.getString('danh_sach_tai_khoan'),
        'luu_dang_nhap': prefs.getBool('luu_dang_nhap'),
        'luu_so_dien_thoai': prefs.getString('luu_so_dien_thoai'),
        'luu_mat_khau': prefs.getString('luu_mat_khau'),
        'currentUserPhone': prefs.getString('currentUserPhone'),
        'isLoggedIn': prefs.getBool('isLoggedIn'),
      };

      await _firestore.collection('user_backups').doc(userId).set(dataToBackup);
      print('Backup successful for $userId');
    } catch (e) {
      print('Backup error for $userId: $e');
    }
  }

  Future<void> restoreData(String userId) async {
    try {
      print('Restoring data for user: $userId');
      final prefs = await SharedPreferences.getInstance();
      DocumentSnapshot doc = await _firestore.collection('user_backups').doc(userId).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('Data found for restore: $data');
        if (data['danh_sach_tai_khoan'] != null) await prefs.setString('danh_sach_tai_khoan', data['danh_sach_tai_khoan']);
        if (data['luu_dang_nhap'] != null) await prefs.setBool('luu_dang_nhap', data['luu_dang_nhap']);
        if (data['luu_so_dien_thoai'] != null) await prefs.setString('luu_so_dien_thoai', data['luu_so_dien_thoai']);
        if (data['luu_mat_khau'] != null) await prefs.setString('luu_mat_khau', data['luu_mat_khau']);
        if (data['currentUserPhone'] != null) await prefs.setString('currentUserPhone', data['currentUserPhone']);
        if (data['isLoggedIn'] != null) await prefs.setBool('isLoggedIn', data['isLoggedIn']);
        print('Restore successful for $userId');
      } else {
        print('No backup data found for $userId');
      }
    } catch (e) {
      print('Restore error for $userId: $e');
    }
  }
}