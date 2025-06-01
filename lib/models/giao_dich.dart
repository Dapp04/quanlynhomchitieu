class GiaoDich {
  final String loai;
  final double soTien;
  final String moTa;
  final DateTime ngayGio;
  final String nhom;
  final String tenKhoan; // Thêm trường tenKhoan

  GiaoDich({
    required this.loai,
    required this.soTien,
    required this.moTa,
    required this.ngayGio,
    required this.nhom,
    required this.tenKhoan, required String ngay,
  });

  Map<String, dynamic> toJson() {
    return {
      'loai': loai,
      'soTien': soTien,
      'moTa': moTa,
      'ngayGio': ngayGio.toIso8601String(),
      'nhom': nhom,
      'tenKhoan': tenKhoan, // Lưu tenKhoan
    };
  }

  factory GiaoDich.fromJson(Map<String, dynamic> json) {
    DateTime ngayGio;
    if (json['ngayGio'] != null) {
      // Dữ liệu mới: Lấy từ chuỗi ISO 8601
      ngayGio = DateTime.parse(json['ngayGio']);
    } else if (json['ngay'] != null) {
      // Dữ liệu cũ: Chuyển chuỗi "dd/mm/yyyy" thành DateTime
      try {
        final parts = json['ngay'].split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          ngayGio = DateTime(year, month, day, 0, 0); // Giờ mặc định 00:00
        } else {
          ngayGio = DateTime.now(); // Dự phòng
        }
      } catch (e) {
        ngayGio = DateTime.now(); // Dự phòng nếu lỗi
      }
    } else {
      ngayGio = DateTime.now(); // Dự phòng
    }

    return GiaoDich(
      loai: json['loai'] ?? 'Chi tiêu',
      soTien: (json['soTien'] as num?)?.toDouble() ?? 0.0,
      moTa: json['moTa'] ?? 'Mô tả',
      ngayGio: ngayGio,
      nhom: json['nhom'] ?? 'Khác',
      tenKhoan: json['tenKhoan'] ?? '', ngay: '',
    );
  }
}