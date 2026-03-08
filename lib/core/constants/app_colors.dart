import 'package:flutter/material.dart';

class AppColors {
  // ==========================================
  // Brand Colors (From Green & Genoa Palettes)
  // ==========================================
  static const Color primary = Color(0xFF00A991); // Green Normal
  static const Color primaryDark = Color(0xFF11302d); // Genoa 700 (Used for AppBars/Headers)
  static const Color primaryLight = Color(0xFFE6F6F4);
  static const Color glassColor = Color(0x330F766E);

  // Green Light (Used for light accents/bubbles)
  static const Color genoa950 = Color(0xFF022B28);
  static const Color genoa900 = Color(0xFF064B47);
  static const Color genoa800 = Color(0xFF095B56);
  static const Color genoa700 = Color(0xFF0F766E);
  static const Color genoa600 = Color(0xFF19A498);
  static const Color genoa550 = Color(0xFF92BEBA);
  static const Color genoa500 = Color(0xFF21C8B9);
  static const Color greenDark = Color(0xFF007F6D);

  // ==========================================
  // Grayscale Colors (From Woodsmoke Palette)
  // ==========================================
  static const Color woodsmoke50 = Color(0xFFFAFAFA);
  static const Color woodsmoke100 = Color(0xFFF4F4F4);
  static const Color woodsmoke200 = Color(0xFFE5E5E5);
  static const Color woodsmoke400 = Color(0xFF929292);
  static const Color woodsmoke600 = Color(0xFF505050);
  static const Color woodsmoke800 = Color(0xFF222222);
  static const Color woodsmoke900 = Color(0xFF121212);
  static const Color woodsmoke950 = Color(0xFF050505);
  // ==========================================
  // Light Mode Mapping
  // ==========================================
  static const Color lightBackground = woodsmoke50; // #FAFAFA
  static const Color lightSurface = Colors.white;
  static const Color lightInputFill = woodsmoke50;
  static const Color lightPrimaryText = woodsmoke900; // #121212
  static const Color lightSecondaryText = woodsmoke600; // #505050
  static const Color lightBorder = woodsmoke200; // #E5E5E5

  // ==========================================
  // Dark Mode Mapping
  // ==========================================
  static const Color darkBackground = woodsmoke950; // #050505 (Very dark as seen in UI)
  static const Color darkSurface = woodsmoke800; // #222222 (Cards, Chat Bubbles, Bottom Nav)
  static const Color darkInputFill =
      woodsmoke900; // #121212 (Slightly lighter than bg for inputs)
  static const Color darkPrimaryText = woodsmoke50; // #FAFAFA
  static const Color darkSecondaryText = woodsmoke400; // #929292
  static const Color darkBorder = woodsmoke600; // #505050

  // ==========================================
  // Utility Colors
  // ==========================================
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF14AE5C);
  static const Color transparent = Colors.transparent;
}
