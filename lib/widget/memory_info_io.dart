import 'dart:io';

const int _bytesPerMB = 1024 * 1024;

/// ネイティブ環境: ProcessInfoから取得
String formatRss() =>
    '${(ProcessInfo.currentRss / _bytesPerMB).toStringAsFixed(1)} MB';

String formatMaxRss() =>
    '${(ProcessInfo.maxRss / _bytesPerMB).toStringAsFixed(1)} MB';
