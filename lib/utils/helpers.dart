// ignore_for_file: avoid_print

import '../models/giao_dich.dart';

String layNgayHienTai() {
  DateTime now = DateTime.now();
  List<String> thuTrongTuan = [
    'Chủ Nhật',
    'Thứ Hai',
    'Thứ Ba',
    'Thứ Tư',
    'Thứ Năm',
    'Thứ Sáu',
    'Thứ Bảy',
  ];
  String thu = thuTrongTuan[now.weekday % 7];
  return '$thu, ngày ${now.day} tháng ${now.month}';
}

Map<String, Map<String, double>> tinhTongTheoNhom(List<GiaoDich> giaoDichList, int thang, int nam) {
  Map<String, Map<String, double>> ketQua = {
    'Chi tiêu': {
      'Đồ ăn': 0.0,
      'Mua sắm': 0.0,
      'Giải trí': 0.0,
      'Du lịch': 0.0,
      'Học tập': 0.0,
      'Khác': 0.0,
    },
    'Thu nhập': {
      'Đồ ăn': 0.0,
      'Mua sắm': 0.0,
      'Giải trí': 0.0,
      'Du lịch': 0.0,
      'Học tập': 0.0,
      'Khác': 0.0,
    },
  };

  for (var giaoDich in giaoDichList) {
    try {
      final giaoDichThang = giaoDich.ngayGio.month;
      final giaoDichNam = giaoDich.ngayGio.year;

      if (giaoDichThang == thang && giaoDichNam == nam) {
        final nhom = giaoDich.nhom;
        final loai = giaoDich.loai;
        if (ketQua[loai]!.containsKey(nhom)) {
          ketQua[loai]![nhom] = (ketQua[loai]![nhom] ?? 0.0) + giaoDich.soTien;
        } else {
          ketQua[loai]!['Khác'] = (ketQua[loai]!['Khác'] ?? 0.0) + giaoDich.soTien;
        }
      }
    } catch (e) {
      print('Lỗi khi xử lý giao dịch: $e, Ngày: ${giaoDich.ngayGio}');
      continue;
    }
  }

  print('Tổng theo nhóm (Tháng $thang/Năm $nam): $ketQua');
  return ketQua;
}

double tinhTong(Map<String, double> nhom) {
  return nhom.values.fold(0.0, (sum, value) => sum + value);
}

MapEntry<String, double> timNhomLonNhat(Map<String, double> nhom) {
  return nhom.entries.reduce((a, b) => a.value > b.value ? a : b);
}