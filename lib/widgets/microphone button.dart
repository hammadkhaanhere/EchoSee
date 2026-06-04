import 'package:flutter/material.dart';

class MicrophoneButton extends StatelessWidget {
  const MicrophoneButton({
    super.key,
    required this.isListening,
    required this.isInitializing,
    required this.onPressed,
  });

  final bool isListening;
  final bool isInitializing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox.square(
      dimension: 96,
      child: FilledButton(
        onPressed: isInitializing ? null : onPressed,
        style: FilledButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: isListening
              ? colorScheme.error
              : colorScheme.primary,
        ),
        child: Icon(
          isListening
              ? Icons.stop_rounded
              : Icons.mic_rounded,
          size: 42,
        ),
      ),
    );
  }
}