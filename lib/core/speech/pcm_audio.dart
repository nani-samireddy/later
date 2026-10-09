import 'dart:typed_data';

Float32List pcm16ToFloat32(Uint8List bytes) {
  final result = Float32List(bytes.length ~/ 2);
  final data = ByteData.sublistView(bytes);
  for (var i = 0; i < result.length; i++) {
    result[i] = data.getInt16(i * 2, Endian.little) / 32768.0;
  }
  return result;
}
