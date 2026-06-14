import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        _section(context, ref, 'Antiguo Testamento', Testament.old),
        const SizedBox(height: 24),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: books.map((b) => _BookCard(
                book: b,
                isSelected: b.id == selected.id,
                completed: ref.watch(userProgressProvider).completedFor(b.id).length,
                onTap: () {
                  ref.read(userProgressProvider.notifier).selectBook(b.id);
                  ref.read(navigationProvider.notifier).setTab(0);
                },
              )).toList(),
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.blue[900] : Colors.blue[50])
              : Theme.of(context).cardColor,
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _MiniSheepHead(woolColor: book.woolColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.primaryDark : null,
                    ),
                  ),
                  Text(
                    '$completed / ${book.chapters} cap.',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniSheepHead extends StatelessWidget {
  final Color woolColor;
  
  const _MiniSheepHead({required this.woolColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: CustomPaint(
        painter: _MiniSheepHeadPainter(woolColor: woolColor),
      ),
    );
  }
}

class _MiniSheepHeadPainter extends CustomPainter {
  final Color woolColor;
  
  _MiniSheepHeadPainter({required this.woolColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final isDarkWool = woolColor.computeLuminance() < 0.5;
    final outlineColor = isDarkWool ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.1);

    final woolPaint = Paint()..color = woolColor;
    final woolOutline = Paint()..color = outlineColor..style = PaintingStyle.stroke..strokeWidth = 1.5;

    void drawCloud(double x, double y, double r) {
      canvas.drawCircle(Offset(x, y), r, woolPaint);
      canvas.drawCircle(Offset(x, y), r, woolOutline);
    }

    // Lana base (fondo)
    drawCloud(cx, cy - 2, 13);
    drawCloud(cx - 9, cy + 3, 9);
    drawCloud(cx + 9, cy + 3, 9);

    // Cara
    final facePaint = Paint()..color = const Color(0xFF2D3748);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 5), width: 18, height: 14), facePaint);

    // Orejas
    canvas.save();
    canvas.translate(cx - 9, cy + 3);
    canvas.rotate(-0.3);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 6, height: 4), facePaint);
    canvas.restore();

    canvas.save();
    canvas.translate(cx + 9, cy + 3);
    canvas.rotate(0.3);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 6, height: 4), facePaint);
    canvas.restore();

    // Copete de lana (frente)
    drawCloud(cx, cy - 3, 5);
    drawCloud(cx - 4, cy - 2, 4);
    drawCloud(cx + 4, cy - 2, 4);
    
    // Ojos (simples, sin animar por ser un ícono pequeño)
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - 4, cy + 4), 1.5, eyePaint);
    canvas.drawCircle(Offset(cx + 4, cy + 4), 1.5, eyePaint);
  }

  @override
  bool shouldRepaint(covariant _MiniSheepHeadPainter oldDelegate) => oldDelegate.woolColor != woolColor;
}