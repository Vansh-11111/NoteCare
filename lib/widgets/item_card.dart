import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final IconData archiveIcon;
  final String archiveTooltip;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onArchive,
    required this.onDelete,
    this.archiveIcon = Icons.archive_outlined,
    this.archiveTooltip = 'Archive',
  });

  IconData get _typeIcon {
    switch (item.type) {
      case 'link':
        return Icons.link;
      case 'image':
        return Icons.image_outlined;
      default:
        return Icons.notes;
    }
  }

  Color _typeColor(ColorScheme scheme) {
    switch (item.type) {
      case 'link':
        return scheme.tertiaryContainer;
      case 'image':
        return scheme.secondaryContainer;
      default:
        return scheme.primaryContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.fromLTRB(2, 10, 2, 4),
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _typeColor(colorScheme),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_typeIcon, size: 18, color: colorScheme.onSurface),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.title,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onArchive,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(archiveIcon, size: 20, semanticLabel: archiveTooltip),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onDelete,
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.delete_outline, size: 20),
                    ),
                  ),
                ],
              ),
              if (item.content.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  item.content,
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (item.tags.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: item.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                'Updated ${DateFormat('MMM d, yyyy').format(item.updatedAt)}',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}