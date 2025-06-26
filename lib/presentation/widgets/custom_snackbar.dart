import 'package:flutter/material.dart';

enum SnackbarType { success, error, warning, info }

class CustomSnackbar extends StatefulWidget {
  final String message;
  final SnackbarType type;
  final Duration duration;
  final VoidCallback? onTap;
  final bool showCloseButton;
  final EdgeInsets margin;
  final SnackBarBehavior behavior;

  const CustomSnackbar({
    super.key,
    required this.message,
    this.type = SnackbarType.info,
    this.duration = const Duration(seconds: 4),
    this.onTap,
    this.showCloseButton = true,
    this.behavior = SnackBarBehavior.floating,
    this.margin = const EdgeInsets.all(16),
  });

  @override
  State<CustomSnackbar> createState() => _CustomSnackbarState();

  // Static method untuk menampilkan snackbar
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
    bool showCloseButton = true,
    EdgeInsets margin = const EdgeInsets.all(16),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: margin.left,
            right: margin.right,
            child: Material(
              color: Colors.transparent,
              child: CustomSnackbar(
                message: message,
                type: type,
                duration: duration,
                onTap: onTap,
                showCloseButton: showCloseButton,
                margin: EdgeInsets.zero,
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);

    // Auto remove setelah durasi tertentu
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class _CustomSnackbarState extends State<CustomSnackbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case SnackbarType.success:
        return const Color(0xFF10B981);
      case SnackbarType.error:
        return const Color(0xFFEF4444);
      case SnackbarType.warning:
        return const Color(0xFFF59E0B);
      case SnackbarType.info:
        return const Color(0xFF3B82F6);
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case SnackbarType.success:
        return Icons.check_circle_outline;
      case SnackbarType.error:
        return Icons.error_outline;
      case SnackbarType.warning:
        return Icons.warning_amber_outlined;
      case SnackbarType.info:
        return Icons.info_outline;
    }
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) {
        // Remove overlay jika diperlukan
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: widget.margin,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            shadowColor: Colors.black.withOpacity(0.3),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getBackgroundColor(),
                    _getBackgroundColor().withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Glassmorphism effect
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getIcon(),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Message
                          Expanded(
                            child: Text(
                              widget.message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                          // Close button
                          if (widget.showCloseButton) ...[
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: _dismiss,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Progress indicator
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: TweenAnimationBuilder<double>(
                        duration: widget.duration,
                        tween: Tween<double>(begin: 1.0, end: 0.0),
                        builder: (context, value, child) {
                          return LinearProgressIndicator(
                            value: value,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.8),
                            ),
                            minHeight: 3,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
