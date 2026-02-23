import 'package:flutter/material.dart';

class AppColors {
  // --- Brand ---
  static const Color primaryBlue = Color(0xFF3B82F6); // Vibrant Blue
  static const Color primarySky = Color(0xFF0EA5E9);  // Sky Blue for gradients
  
  // --- Light Theme ---
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightMuted = Color(0xFF64748B);

  // --- Dark Theme (Shadcn Dark) ---
  static const Color darkBackground = Color(0xFF030712); 
  static const Color darkSurface = Color(0xFF090E1B);   
  static const Color darkSurface2 = Color(0xFF111827);  
  static const Color darkBorder = Color(0xFF1F2937);    
  static const Color darkForeground = Color(0xFFF8FAFC);
  static const Color darkMuted = Color(0xFF94A3B8);

  // --- Accents & Status ---
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF0EA5E9);

  // --- Gradients ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primarySky],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Shadows ---
  static List<BoxShadow> get shadowSm => [
    BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 2, offset: const Offset(0, 1)),
  ];
  
  static List<BoxShadow> get shadowMd => [
    BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 10, offset: const Offset(0, 4)),
  ];
}
