import 'package:flutter/material.dart';

class MdrIcon extends StatelessWidget {
  ///合字
  final String? ligature;
  final double? size;
  final Color color;

  MdrIcon(this.ligature, {Key? key, this.size, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    final double? iconSize = size ?? iconTheme.size;

    if (this.ligature == null) {
      return SizedBox(
        width: iconSize,
        height: iconSize,
      );
    }

    final double iconOpacity = iconTheme.opacity ?? 1.0;
    var iconColor = color;
    if (iconOpacity != 1.0)
      iconColor = iconColor.withOpacity(iconColor.opacity * iconOpacity);

    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: RichText(
        overflow: TextOverflow.visible,
        text: TextSpan(
          text: ligature,
          style: TextStyle(
            inherit: false,
            color: iconColor,
            fontSize: iconSize,
            fontFamily: 'Material Icons Round',
          ),
        ),
      ),
    );
  }
}
