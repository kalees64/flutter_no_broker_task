import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Headings (Poppins — rounded, friendly, modern)
  // H1: 24sp Bold
  static TextStyle get h1 => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.5,
        color: AppColors.onSurface,
      );

  // H2: 20sp SemiBold
  static TextStyle get h2 => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: -0.3,
        color: AppColors.onSurface,
      );

  // H3 / Subtitles
  static TextStyle get h3 => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: AppColors.onSurface,
      );

  static TextStyle get titleMedium => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: AppColors.onSurface,
      );

  static TextStyle get titleMd => titleMedium;

  // Body & Inputs (Inter — high readability at small sizes)
  // Body: 14–15sp Regular
  static TextStyle get body => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyMd => body;
  static TextStyle get bodyMedium => body;

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.onSurfaceVariant,
      );

  static TextStyle get bodySm => bodySmall;

  // Caption: 12sp Regular
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.outline,
      );

  // Action labels
  static TextStyle get buttonLabel => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: Colors.white,
      );

  static TextStyle get labelLg => buttonLabel;

  static TextStyle get labelMd => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: AppColors.onSurface,
      );

  static TextStyle get labelSm => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: AppColors.onSurfaceVariant,
      );

  static TextStyle get chipLabel => labelMd;
}
