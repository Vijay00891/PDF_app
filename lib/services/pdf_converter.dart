import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;
import 'package:image/image.dart' as img;
import 'package:pdfx/pdfx.dart' as pdfx;

class PdfConverterService {
  /// Converts a PDF file to a list of JPG images (as bytes).
  /// Note: Pure offline PDF rendering is limited in Flutter without heavy native dependencies.
  /// We will use a placeholder or informational message if rendering fails.
  static Future<List<Uint8List>> pdfToJpg(File pdfFile) async {
    // Native PDF rendering using pdfx
    final document = await pdfx.PdfDocument.openFile(pdfFile.path);
    final pagesCount = document.pagesCount;
    List<Uint8List> images = [];

    for (int i = 1; i <= pagesCount; i++) {
      final page = await document.getPage(i);

      // Render the page as image with higher resolution
      final pageImage = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: pdfx.PdfPageImageFormat.jpeg,
      );

      if (pageImage?.bytes != null) {
        images.add(pageImage!.bytes);
      }

      await page.close();
    }

    await document.close();

    if (images.isEmpty) {
      throw Exception("Failed to natively render PDF to images offline.");
    }

    return images;
  }

  static Future<Uint8List> docToPdf(File docFile) async {
    final pdf = pw.Document();

    // Basic offline mock since syncfusion_flutter_word/presentation isn't available
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Offline Document to PDF Conversion',
                  style: pw.TextStyle(fontSize: 24),
                ),
                pw.SizedBox(height: 20),
                pw.Text('File: ${docFile.path.split('/').last}'),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Note: Full DOCX/PPTX rendering requires cloud APIs or heavy native libraries.',
                ),
              ],
            ),
          );
        },
      ),
    );

    return await pdf.save();
  }

  /// Converts a list of image files to a single PDF document.
  static Future<Uint8List> imagesToPdf(List<File> imageFiles) async {
    final pdf = pw.Document();

    for (var imageFile in imageFiles) {
      final bytes = await imageFile.readAsBytes();
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) continue;

      final image = pw.MemoryImage(bytes);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(image));
          },
        ),
      );
    }

    return await pdf.save();
  }

  /// Converts a PDF to a very basic DOCX (Text only extraction)
  /// This is the most we can do 100% offline without syncfusion_flutter_word.
  static Future<String> extractText(File pdfFile) async {
    final sf.PdfDocument document = sf.PdfDocument(
      inputBytes: await pdfFile.readAsBytes(),
    );
    String text = sf.PdfTextExtractor(document).extractText();
    document.dispose();
    return text;
  }
}
