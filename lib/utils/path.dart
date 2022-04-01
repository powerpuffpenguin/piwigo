import 'package:path/path.dart' as path;

bool isVideoFile(String file) {
  final ext = path.extension(file).toLowerCase();
  return ext == '.ogg' ||
      ext == '.ogv' ||
      ext == '.mp4' ||
      ext == '.m4v' ||
      ext == '.webm' ||
      ext == '.webmv' ||
      ext == '.strm';
}
