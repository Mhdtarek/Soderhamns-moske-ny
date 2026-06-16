import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:soderhamns_moske_app/data/models/news_post.dart';
import 'package:soderhamns_moske_app/features/news/providers/news_providers.dart';
import 'package:soderhamns_moske_app/shared/widgets/error_view.dart';
import 'package:soderhamns_moske_app/shared/widgets/loading_view.dart';

const _grey888 = Color(0xFF888888);
const _grey333 = Color(0xFF333333);
const _dark = Color(0xFF2C2A22);
const _green = Color(0xFF4A7C59);
const _dividerLight = Color(0x1A000000);

class LatestNewsCard extends ConsumerWidget {
  final AsyncValue<List<NewsPost>> newsAsync;

  const LatestNewsCard({super.key, required this.newsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return newsAsync.when(
      loading: () => Card(
        child: SizedBox(height: 100, child: Center(child: LoadingView())),
      ),
      error: (_, __) => Card(
        child: ErrorView(
          message: 'Kunde inte ladda nyheter',
          onRetry: () => ref.invalidate(newsListProvider),
        ),
      ),
      data: (posts) {
        if (posts.isEmpty) return const SizedBox.shrink();

        final sorted = List<NewsPost>.from(posts)
          ..sort((a, b) => b.date.compareTo(a.date));
        final latest = sorted.take(2).toList();

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Nyheter',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _dark,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Icon(Icons.newspaper, size: 16, color: _grey888),
                  ],
                ),
              ),
              for (var i = 0; i < latest.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 0.5,
                    color: _dividerLight,
                  ),
                _HomeNewsRow(
                  post: latest[i],
                  onTap: () => context.go('/nyheter/${latest[i].slug}'),
                ),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: InkWell(
                  onTap: () => context.go('/nyheter'),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Visa alla',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _green,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.arrow_forward, size: 12, color: _green),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeNewsRow extends StatelessWidget {
  const _HomeNewsRow({required this.post, required this.onTap});

  final NewsPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = post.imageUrl != null && post.imageUrl!.isNotEmpty;
    final dateStr = _formatRowDate(post.date);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        child: Row(
          children: [
            if (hasImage)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: post.imageUrl!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 44,
                      height: 44,
                      color: const Color(0xFFE8E4D8),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 44,
                      height: 44,
                      color: const Color(0xFFE8E4D8),
                      child: const Icon(
                        Icons.article_outlined,
                        size: 20,
                        color: _grey888,
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _grey333,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: const TextStyle(fontSize: 11, color: _grey888),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: _grey888),
          ],
        ),
      ),
    );
  }

  static String _formatRowDate(DateTime date) {
    try {
      return intl.DateFormat('d MMM y', 'sv').format(date);
    } catch (_) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}
