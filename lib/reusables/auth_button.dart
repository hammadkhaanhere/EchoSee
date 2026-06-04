import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum ButtonStatus { idle, loading, success }

class AuthButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonStatus status;
  final int shakeKey;

  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.status = ButtonStatus.idle,
    this.shakeKey = 0,
  });

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeCtrl;
  late Animation<Offset> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = TweenSequence<Offset>([
      TweenSequenceItem(
          tween: Tween(begin: Offset.zero, end: const Offset(8, 0)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(8, 0), end: const Offset(-8, 0)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(-8, 0), end: const Offset(6, 0)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(6, 0), end: const Offset(-6, 0)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(-6, 0), end: const Offset(3, 0)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(3, 0), end: Offset.zero),
          weight: 1),
    ]).animate(
        CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(AuthButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shakeKey != oldWidget.shakeKey) {
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeCtrl,
      builder: (context, _) {
        return Transform.translate(
          offset: _shakeAnim.value,
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: widget.status == ButtonStatus.loading
                  ? null
                  : widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.teal.withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _buildChild(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChild() {
    switch (widget.status) {
      case ButtonStatus.idle:
        return Text(widget.label,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600));
      case ButtonStatus.loading:
        return const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      case ButtonStatus.success:
        return const Icon(Icons.check_circle, color: Colors.white, size: 28);
    }
  }
}
