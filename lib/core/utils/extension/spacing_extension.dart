import 'package:flutter/widgets.dart';

extension SpacingExtension on num {
  SizedBox get height => SizedBox(height: toDouble());
  SizedBox get width => SizedBox(width: toDouble());
}
