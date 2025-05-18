import 'package:flutter/cupertino.dart';

extension SizeBoxExtension on num {
  Widget sizeBoxHeight() => SizedBox(
        height: toDouble(),
      );

  Widget sizeBoxWidth() => SizedBox(
        width: toDouble(),
      );
}
