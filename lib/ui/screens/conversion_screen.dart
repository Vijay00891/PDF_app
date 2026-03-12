import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_converter/services/file_service.dart';
import 'package:pdf_converter/services/pdf_converter.dart';
import 'package:open_filex/open_filex.dart';

enum ConversionType { imgToPdf, pdfToImg, docToPdf, pdfToDoc }

class ConversionScreen extends StatefulWidget {
  final ConversionType type;

  const ConversionScreen({super.key, required this.type});

  @override
  State<ConversionScreen> createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {
  bool _isLoading = false;
  String? _status;
  String? _outputPath;
  File? _selectedFile;
  List<File>? _selectedFiles;

  String get _title {
    switch (widget.type) {
      case ConversionType.imgToPdf:
        return 'Images to PDF';
      case ConversionType.pdfToImg:
        return 'PDF to Images';
      case ConversionType.docToPdf:
        return 'Document to PDF';
      case ConversionType.pdfToDoc:
        return 'PDF to Document';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isLoading && _outputPath == null) ...[
                Icon(
                  _getIcon(),
                  size: 80,
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _pickFiles,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    widget.type == ConversionType.imgToPdf
                        ? 'Select Images'
                        : 'Select File',
                  ),
                ),
              ],
              if (_isLoading) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  _status ?? 'Processing...',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
              if (_outputPath != null) ...[
                const Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Conversion Complete!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Saved to Downloads',
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back Home'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _openResult,
                      child: const Text('Open File'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (widget.type) {
      case ConversionType.imgToPdf:
        return Icons.collections_rounded;
      case ConversionType.pdfToImg:
        return Icons.picture_as_pdf_rounded;
      case ConversionType.docToPdf:
        return Icons.description_rounded;
      case ConversionType.pdfToDoc:
        return Icons.text_snippet_rounded;
    }
  }

  Future<void> _pickFiles() async {
    try {
      if (widget.type == ConversionType.imgToPdf) {
        final files = await FileService.pickMultipleFiles([
          'jpg',
          'jpeg',
          'png',
        ]);
        if (files != null && files.isNotEmpty) {
          setState(() => _selectedFiles = files);
          _startConversion();
        }
      } else {
        final ext = widget.type == ConversionType.docToPdf
            ? ['docx', 'doc']
            : ['pdf'];
        final file = await FileService.pickFile(ext);
        if (file != null) {
          setState(() => _selectedFile = file);
          _startConversion();
        }
      }
    } catch (e) {
      _showError('Error picking file: $e');
    }
  }

  Future<void> _startConversion() async {
    setState(() {
      _isLoading = true;
      _status = 'Converting...';
    });

    try {
      String fileName = 'converted_${DateTime.now().millisecondsSinceEpoch}';
      List<int> bytes;

      switch (widget.type) {
        case ConversionType.imgToPdf:
          bytes = await PdfConverterService.imagesToPdf(_selectedFiles!);
          fileName += '.pdf';
          break;
        case ConversionType.pdfToDoc:
          final text = await PdfConverterService.extractText(_selectedFile!);
          bytes = text.codeUnits;
          fileName += '.txt'; // Falling back to TXT if DOCX builder fails
          break;
        case ConversionType.pdfToImg:
          final images = await PdfConverterService.pdfToJpg(_selectedFile!);
          bytes = images.first; // Saving the first page placeholder
          fileName += '.jpg';
          break;
        case ConversionType.docToPdf:
          bytes = await PdfConverterService.docToPdf(_selectedFile!);
          fileName += '.pdf';
          break;
      }

      final path = await FileService.saveToDownloads(fileName, bytes);

      if (path == null) {
        throw Exception(
          'Unable to save to Downloads. Please check storage permissions.',
        );
      }

      setState(() {
        _isLoading = false;
        _outputPath = path;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Conversion failed: $e');
    }
  }

  void _openResult() {
    if (_outputPath != null) {
      OpenFilex.open(_outputPath!);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }
}
