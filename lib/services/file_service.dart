import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;

class FileService {
  static Future<File?> pickFile(List<String> extensions) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  static Future<List<File>?> pickMultipleFiles(List<String> extensions) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      allowMultiple: true,
    );

    if (result != null) {
      return result.paths.whereType<String>().map((path) => File(path)).toList();
    }
    return null;
  }

  static Future<String?> saveToDownloads(String fileName, List<int> bytes) async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.request().isGranted || 
          await Permission.storage.request().isGranted) {
        
        Directory? downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }

        if (downloadsDir != null) {
          final filePath = p.join(downloadsDir.path, fileName);
          final file = File(filePath);
          await file.writeAsBytes(bytes);
          return filePath;
        }
      }
    } else {
      // For other platforms (development)
      final dir = await getApplicationDocumentsDirectory();
      final filePath = p.join(dir.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return filePath;
    }
    return null;
  }

  static String getBaseName(String path) {
    return p.basenameWithoutExtension(path);
  }
}
