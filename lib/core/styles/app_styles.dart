import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyle {
  // Tiêu đề lớn
  static TextStyle heading1 = GoogleFonts.beVietnamPro(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  // Tiêu đề phụ
  static TextStyle heading2 = GoogleFonts.beVietnamPro(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  // Nội dung văn bản bình thường
  static TextStyle bodyText = GoogleFonts.beVietnamPro(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black,
  );

  // Văn bản chú thích
  static TextStyle caption = GoogleFonts.beVietnamPro(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );
}