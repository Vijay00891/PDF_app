import 'package:flutter/material.dart';
import 'package:pdf_converter/services/file_service.dart';
import 'package:pdf_converter/ui/widgets/conversion_card.dart';
import 'package:pdf_converter/ui/screens/conversion_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DocShift',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What would you like to do?',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  ConversionCard(
                    title: 'Images to PDF',
                    icon: Icons.image_outlined,
                    color: Colors.blueAccent,
                    onTap: () => _handleConversion(context, 'IMG_TO_PDF'),
                  ),
                  ConversionCard(
                    title: 'PDF to Images',
                    icon: Icons.picture_as_pdf_outlined,
                    color: Colors.orangeAccent,
                    onTap: () => _handleConversion(context, 'PDF_TO_IMG'),
                  ),
                  ConversionCard(
                    title: 'Document to PDF',
                    icon: Icons.description_outlined,
                    color: Colors.greenAccent,
                    onTap: () => _handleConversion(context, 'DOC_TO_PDF'),
                  ),
                  ConversionCard(
                    title: 'PDF to Document',
                    icon: Icons.text_snippet_outlined,
                    color: Colors.redAccent,
                    onTap: () => _handleConversion(context, 'PDF_TO_DOC'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleConversion(BuildContext context, String type) {
    ConversionType conversionType;
    switch (type) {
      case 'IMG_TO_PDF':
        conversionType = ConversionType.imgToPdf;
        break;
      case 'PDF_TO_IMG':
        conversionType = ConversionType.pdfToImg;
        break;
      case 'DOC_TO_PDF':
        conversionType = ConversionType.docToPdf;
        break;
      case 'PDF_TO_DOC':
        conversionType = ConversionType.pdfToDoc;
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversionScreen(type: conversionType),
      ),
    );
  }
}
