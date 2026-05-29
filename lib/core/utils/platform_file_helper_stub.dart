import 'dart:typed_data';

abstract class PlatformFileHelper {
  static Future<void> saveAndOpenFile(Uint8List bytes, String fileName) {
    throw UnsupportedError('Cannot save and open file without platform implementation');
  }
}
