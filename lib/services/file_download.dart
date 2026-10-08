import 'dart:typed_data';

import 'file_download_stub.dart'
    if (dart.library.html) 'file_download_web.dart' as platform;

void downloadFile(String name, Uint8List bytes) => platform.downloadFile(name, bytes);

void openFile(String name, Uint8List bytes) => platform.openFile(name, bytes);