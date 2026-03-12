import 'package:flutter/material.dart';
import 'package:pdf_converter/utils/theme.dart';
import 'package:pdf_converter/ui/screens/home_screen.dart';

void main() {
  runApp(const PdfConverterApp());
}

class PdfConverterApp extends StatelessWidget {
  const PdfConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocShift Offline',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
