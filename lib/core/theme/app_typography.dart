import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Display styles - for large numbers and prominent text
  static TextStyle displayLarge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
      color: Theme.of(context).colorScheme.onSurface,
    ).copyWith(inherit: false);
  }

  static TextStyle displayMedium(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.3,
      color: Theme.of(context).colorScheme.onSurface,
    ).copyWith(inherit: false);
  }

  // Headline styles - for screen titles and section headers
  static TextStyle headlineLarge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: Theme.of(context).colorScheme.onSurface,
    ).copyWith(inherit: false);
  }

  static TextStyle headlineMedium(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.15,
      color: Theme.of(context).colorScheme.onSurface,
    ).copyWith(inherit: false);
  }

  // Title styles - for card titles and list items
  static TextStyle titleLarge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: Theme.of(context).colorScheme.onSurface,
    ).copyWith(inherit: false);
  }

  static TextStyle titleMedium(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: Theme.of(context).colorScheme.onSurface,
    ).copyWith(inherit: false);
  }

  static TextStyle titleSmall(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: Theme.of(context).colorScheme.onSurface,
    ).copyWith(inherit: false);
  }

  // Body styles - for general text content
  static TextStyle bodyLarge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      color: Theme.of(context).colorScheme.onSurface,
    ).copyWith(inherit: false);
  }

  static TextStyle bodyMedium(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: Theme.of(context).colorScheme.onSurface,
    ).copyWith(inherit: false);
  }

  static TextStyle bodySmall(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
    ).copyWith(inherit: false);
  }

  // Label styles - for buttons and small UI elements
  static TextStyle labelLarge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: Theme.of(context).colorScheme.onSurface,
    ).copyWith(inherit: false);
  }

  static TextStyle labelMedium(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: Theme.of(context).colorScheme.onSurface,
    ).copyWith(inherit: false);
  }

  static TextStyle labelSmall(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
    ).copyWith(inherit: false);
  }
}
