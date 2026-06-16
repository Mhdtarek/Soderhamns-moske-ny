import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:soderhamns_moske_app/core/config/env.dart';
import 'package:soderhamns_moske_app/core/error/app_exception.dart';
import 'package:soderhamns_moske_app/core/router/routes.dart';
import 'package:soderhamns_moske_app/features/news/providers/news_providers.dart';
import 'package:soderhamns_moske_app/shared/widgets/error_view.dart';
import 'package:soderhamns_moske_app/shared/widgets/loading_view.dart';

class NewsDetailScreen extends ConsumerWidget {
  final String slug;

  const NewsDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(newsDetailProvider(slug));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const BackButtonIcon(),
          onPressed: () => context.go(Routes.news),
        ),
        title: Text(detailAsync.valueOrNull?.title ?? 'Nyhet'),
        actions: [
          if (detailAsync.valueOrNull != null)
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Dela',
              onPressed: () => Share.share(
                '${detailAsync.valueOrNull!.title}\n${Env.prayerApiBase}/nyheter/$slug',
                subject: detailAsync.valueOrNull!.title,
              ),
            ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) {
          final message = error is NetworkException
              ? 'Ingen internetanslutning'
              : 'Kunde inte ladda artikeln';
          return ErrorView(
            message: message,
            onRetry: () => ref.invalidate(newsDetailProvider(slug)),
          );
        },
        data: (post) {
          if (post == null) {
            return const Center(child: Text('Artikeln kunde inte hittas'));
          }

          final hasImage =
              post.imageUrl != null && post.imageUrl!.isNotEmpty;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasImage) _buildImage(post.imageUrl!, context),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    hasImage ? 20 : 16,
                    16,
                    16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDate(post.date, context),
                      const SizedBox(height: 8),
                      Text(
                        post.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (post.body != null && post.body!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildMarkdown(post.body!, context),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(String imageUrl, BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: double.infinity,
      height: 220,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        height: 220,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (_, __, ___) => Container(
        height: 220,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: Icon(Icons.broken_image, size: 48)),
      ),
    );
  }

  Widget _buildDate(DateTime date, BuildContext context) {
    final formatted = _formatDate(date);
    return Text(
      formatted,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }

  Widget _buildMarkdown(String body, BuildContext context) {
    final theme = Theme.of(context);
    final styleSheet = MarkdownStyleSheet(
      h1: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      h2: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      h3: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      p: theme.textTheme.bodyLarge?.copyWith(
        height: 1.6,
      ),
      listBullet: theme.textTheme.bodyLarge,
      strong: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      em: theme.textTheme.bodyLarge?.copyWith(
        fontStyle: FontStyle.italic,
      ),
      code: theme.textTheme.bodySmall?.copyWith(
        fontFamily: 'monospace',
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
      ),
      codeblockDecoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary,
            width: 4,
          ),
        ),
        color: theme.colorScheme.surfaceContainerLow,
      ),
      blockquote: theme.textTheme.bodyMedium?.copyWith(
        fontStyle: FontStyle.italic,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      a: TextStyle(color: theme.colorScheme.primary),
    );

    return MarkdownBody(
      data: body,
      styleSheet: styleSheet,
      selectable: true,
      imageBuilder: (uri, title, alt) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              uri.toString(),
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                final total = loadingProgress.expectedTotalBytes;
                return Container(
                  height: 200,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Center(child: Icon(Icons.broken_image, size: 48)),
                );
              },
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('d MMMM y', 'sv').format(date);
    } catch (_) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}
