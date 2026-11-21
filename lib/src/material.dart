// Single entry point to the Material library for chatx.
//
// Flutter 3.50 deprecated `package:flutter/material.dart` in favor of the
// `material_ui` package. The two libraries define separate types, and there
// is no bridge for apps that still use `flutter/material.dart` to host widgets
// built on `material_ui`. chatx therefore stays on `flutter/material.dart` so
// it works in every app. Apps that migrated to `material_ui` wrap chatx in
// `MaterialUiCompatibilityBridge` (see README).
//
// ignore: deprecated_member_use
export 'package:flutter/material.dart';
