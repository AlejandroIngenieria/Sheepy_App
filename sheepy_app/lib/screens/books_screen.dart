import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_theme.dart';
import '../data/bible_books.dart';
import '../models/bible_book.dart';
import '../providers/providers.dart';

class BooksScreen extends ConsumerWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '📚 Biblioteca',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Elige un libro para empezar tu aventura',
          style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        _section(context, ref, 'Antiguo Testamento', Testament.old),
        const SizedBox(height: 28),
        _section(context, ref, 'Nuevo Testamento', Testament.nuevo),
      ],
    );
  }

  Widget _section(
    BuildContext context,
    WidgetRef ref,
    String title,
    Testament testament,
  ) {
    final books = booksByTestament(testament);
    final selected = ref.watch(selectedBookProvider);
    final asyncProgress = ref.watch(booksProgressProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryDark,
            ),
          ),
        ),
        const SizedBox(height: 14),
        asyncProgress.when(
          data: (progressData) {
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: books.asMap().entries.map((entry) {
                final b = entry.value;
                final match = progressData.where((p) => p['book_number'] == b.bookNumber).firstOrNull;
                final completedCount = match != null ? (match['completed_chapters'] as int) : 0;
                
                return _BookCard(
                  book: b,
                  isSelected: b.id == selected.id,
                  completed: completedCount,
                  onTap: () {
                    ref.read(userProgressProvider.notifier).selectBook(b.id);
                    ref.read(navigationProvider.notifier).setTab(0);
                  },
                ).animate(delay: (entry.key * 30).ms).fadeIn(duration: 300.ms).slideY(begin: 0.08);
              }).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, s) => Text('Error: $e'),
        ),
      ],
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.book,
    required this.isSelected,
    required this.completed,
    required this.onTap,
  });

  final BibleBook book;
  final bool isSelected;
  final int completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = (MediaQuery.sizeOf(context).width - 50) / 2;
    final progressValue = book.chapters > 0 ? completed / book.chapters : 0.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: width,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: isDark ? 0.2 : 0.08)
              : Theme.of(context).cardColor,
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _MiniSheepAvatar(woolColor: book.woolColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    book.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: isSelected ? AppTheme.primaryDark : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Mini progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 5,
                backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.1),
                color: completed == book.chapters ? AppTheme.success : AppTheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$completed / ${book.chapters} cap.',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniSheepAvatar extends StatelessWidget {
  final Color woolColor;
  
  const _MiniSheepAvatar({required this.woolColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: woolColor.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: CustomPaint(
        painter: _MiniSheepPainter(woolColor: woolColor),
      ),
    );
  }
}

class _MiniSheepPainter extends CustomPainter {
  final Color woolColor;
  
  _MiniSheepPainter({required this.woolColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final woolPaint = Paint()..color = woolColor;

    // Wool clusters
    canvas.drawCircle(Offset(cx, cy - 3), 11, woolPaint);
    canvas.drawCircle(Offset(cx - 7, cy + 2), 7, woolPaint);
    canvas.drawCircle(Offset(cx + 7, cy + 2), 7, woolPaint);

    // Face
    final facePaint = Paint()..color = const Color(0xFFFFF5EE);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 4), width: 14, height: 11), facePaint);

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF3D2B1F);
    canvas.drawCircle(Offset(cx - 3, cy + 3), 1.5, eyePaint);
    canvas.drawCircle(Offset(cx + 3, cy + 3), 1.5, eyePaint);

    // Sparkle
    final sparklePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - 3.5, cy + 2), 0.7, sparklePaint);
    canvas.drawCircle(Offset(cx + 2.5, cy + 2), 0.7, sparklePaint);

    // Blush
    final blushPaint = Paint()
      ..color = const Color(0xFFFF9EAA).withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(Offset(cx - 5, cy + 5), 2, blushPaint);
    canvas.drawCircle(Offset(cx + 5, cy + 5), 2, blushPaint);
  }

  @override
  bool shouldRepaint(covariant _MiniSheepPainter oldDelegate) => oldDelegate.woolColor != woolColor;
}