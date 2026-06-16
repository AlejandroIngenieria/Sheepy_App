import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_theme.dart';
import '../models/user_stats.dart';

class LivesWidget extends StatefulWidget {
  const LivesWidget({
    super.key,
    required this.userStats,
    this.onZeroLives,
  });

  final UserStats userStats;
  final VoidCallback? onZeroLives;

  @override
  State<LivesWidget> createState() => _LivesWidgetState();
}

class _LivesWidgetState extends State<LivesWidget> {
  late int _lives;
  late int _secondsUntilNext;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _lives = widget.userStats.currentLives;
    _secondsUntilNext = widget.userStats.minutesUntilNextLife * 60;
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant LivesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userStats.currentLives != widget.userStats.currentLives ||
        oldWidget.userStats.minutesUntilNextLife !=
            widget.userStats.minutesUntilNextLife) {
      _timer?.cancel();
      _lives = widget.userStats.currentLives;
      _secondsUntilNext = widget.userStats.minutesUntilNextLife * 60;
      _startTimer();
    }
  }

  void _startTimer() {
    if (_lives >= 5) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_secondsUntilNext > 0) {
          _secondsUntilNext--;
        } else {
          _lives++;
          if (_lives >= 5) {
            _lives = 5;
            timer.cancel();
          } else {
            _secondsUntilNext = 15 * 60;
          }
        }
      });
      
      if (_lives == 0) {
        widget.onZeroLives?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeString {
    final minutes = _secondsUntilNext ~/ 60;
    final seconds = _secondsUntilNext % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _lives > 0 ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: AppTheme.accent,
            size: 18,
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.2, 1.2),
                duration: 700.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(width: 4),
          Text(
            _lives >= 5 ? '♥' : _lives.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: AppTheme.accent,
            ),
          ),
          if (_lives < 5) ...[
            const SizedBox(width: 4),
            Text(
              _timeString,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w700,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
