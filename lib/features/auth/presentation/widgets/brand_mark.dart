import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({this.compact = false, super.key});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Semantics(
          label: 'Colportando',
          child: Container(
            width: compact ? 44 : 54,
            height: compact ? 44 : 54,
            decoration: BoxDecoration(
              color: BrandColors.charcoal,
              borderRadius: BorderRadius.circular(compact ? 13 : 17),
              boxShadow: [
                BoxShadow(
                  color: BrandColors.sehsBlue.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  color: colors.surface,
                  size: compact ? 25 : 31,
                ),
                Positioned(
                  right: compact ? 5 : 6,
                  top: compact ? 5 : 6,
                  child: Container(
                    width: compact ? 9 : 11,
                    height: compact ? 9 : 11,
                    decoration: const BoxDecoration(
                      color: BrandColors.kerussoLime,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 13),
        if (compact)
          Expanded(child: _BrandLabels(colors: colors))
        else
          _BrandLabels(colors: colors),
      ],
    );
  }
}

class _BrandLabels extends StatelessWidget {
  const _BrandLabels({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Colportando',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        Text(
          'Libros que transforman',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
