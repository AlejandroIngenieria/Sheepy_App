import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../core/lottie_assets.dart';

class LottieLoading extends StatelessWidget {
  const LottieLoading({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          LottieAssets.loading,
          width: 100,
          height: 100,
          repeat: true,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(message!, textAlign: TextAlign.center),
        ],
      ],
    );
  }
}

class LottieCelebration extends StatelessWidget {
  const LottieCelebration({super.key, this.size = 160});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      LottieAssets.celebration,
      width: size,
      height: size,
      repeat: false,
    );
  }
}
