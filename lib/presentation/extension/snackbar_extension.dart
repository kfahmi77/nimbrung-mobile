import 'package:flutter/widgets.dart';

import '../../../presentation/widgets/custom_snackbar.dart';

extension SnackbarExtension on BuildContext {
  void showCustomSnackbar({
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
    bool showCloseButton = true,
  }) {
    CustomSnackbar.show(
      this,
      message: message,
      type: type,
      duration: duration,
      onTap: onTap,
      showCloseButton: showCloseButton,
    );
  }
}
