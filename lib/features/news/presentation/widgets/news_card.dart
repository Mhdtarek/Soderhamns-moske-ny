import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soderhamns_moske_app/data/models/news_post.dart';
import 'package:soderhamns_moske_app/core/theme/app_colors.dart';

class NewsCard extends StatelessWidget {
  final NewsPost post;
  final VoidCallback? onTap;
  final bool isNew;

  const NewsCard({
    super.key,
    required this.post,
    this.onTap,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = post.imageUrl != null && post.imageUrl!.isNotEmpty;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl!,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 160,
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 160,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.article_outlined, size: 32),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge + Date row
                  Row(
                    children: [
                      if (isNew) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.accentGreenLight
                                : AppColors.accentGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Nytt',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.black : Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        _formatDate(context),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isNew
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isNew ? FontWeight.w500 : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Title
                  Text(
                    post.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Excerpt
                  if (post.excerpt.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      post.excerpt,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Read more link
                  Row(
                    children: [
                      Text(
                        'Läs mer',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.accentGreenLight
                              : AppColors.accentGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: isDark
                            ? AppColors.accentGreenLight
                            : AppColors.accentGreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(BuildContext context) {
    try {
      return DateFormat('d MMM y', 'sv').format(post.date);
    } catch (_) {
      return '${post.date.year}-${post.date.month.toString().padLeft(2, '0')}-${post.date.day.toString().padLeft(2, '0')}';
    }
  }
}
