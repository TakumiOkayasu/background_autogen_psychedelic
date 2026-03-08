import 'dart:js_interop';
import 'dart:js_interop_unsafe';

const int _bytesPerMB = 1024 * 1024;

String _readMemoryProperty(String property) {
  try {
    final performance = globalContext['performance'] as JSObject?;
    if (performance == null) return 'N/A';
    final memory = performance['memory'] as JSObject?;
    if (memory == null) return 'N/A';
    final value = (memory[property] as JSNumber?)?.toDartDouble;
    if (value == null) return 'N/A';
    return '${(value / _bytesPerMB).toStringAsFixed(1)} MB';
  } catch (_) {
    return 'N/A';
  }
}

/// Web環境: performance.memory API から取得 (Chrome only)
String formatRss() => _readMemoryProperty('usedJSHeapSize');

String formatMaxRss() => _readMemoryProperty('jsHeapSizeLimit');
