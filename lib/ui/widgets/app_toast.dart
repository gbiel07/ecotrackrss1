import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Aviso flutuante no canto inferior direito (.toast), some após 3 segundos.
abstract final class AppToast {
  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(BuildContext context, String message) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _timer?.cancel();
    _entry?.remove();

    final entry = OverlayEntry(builder: (_) => _ToastView(message: message));
    _entry = entry;
    overlay.insert(entry);
    _timer = Timer(const Duration(seconds: 3), () {
      if (_entry == entry) {
        entry.remove();
        _entry = null;
      }
    });
  }
}

class _ToastView extends StatelessWidget {
  const _ToastView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isNarrow = width < 500;
    return Positioned(
      right: 22,
      left: isNarrow ? 22 : null,
      bottom: 22 + MediaQuery.paddingOf(context).bottom,
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(offset: Offset(0, 12 * (1 - value)), child: child),
          ),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(maxWidth: isNarrow ? width - 44 : 420),
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.toast,
                borderRadius: BorderRadius.circular(9),
                boxShadow: const [
                  BoxShadow(color: Color(0x29000000), blurRadius: 35, offset: Offset(0, 10)),
                ],
              ),
              child: Text(
                message,
                style: const TextStyle(color: AppColors.white, fontSize: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
