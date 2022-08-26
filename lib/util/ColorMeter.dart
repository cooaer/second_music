import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:palette_generator/palette_generator.dart';

class ColorMeter {
  PaletteGenerator? _paletteGenerator;
  String? _lastPicUrl;

  final defTopBarColor = Color(0xff8f8f8f);

  Future<void> _createPaletteGenerator(String picUrl) async {
    if (_paletteGenerator == null || _lastPicUrl != picUrl) {
      _paletteGenerator = await PaletteGenerator.fromImageProvider(
          CachedNetworkImageProvider(picUrl),
          size: Size(140, 140));
    }
    _lastPicUrl = picUrl;
  }

  Future<Color> generateTopBarColor(String picUrl) async {
    if (picUrl.isEmpty) {
      return defTopBarColor;
    }
    await _createPaletteGenerator(picUrl);
    return _topBarColor(_paletteGenerator);
  }

  Color _topBarColor(PaletteGenerator? _paletteGenerator) {
    if (_paletteGenerator == null) return defTopBarColor;
    return _paletteGenerator.dominantColor?.color ??
        _paletteGenerator.lightVibrantColor?.color ??
        _paletteGenerator.lightMutedColor?.color ??
        _paletteGenerator.darkVibrantColor?.color ??
        _paletteGenerator.darkMutedColor?.color ??
        defTopBarColor;
  }
}
