import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:soderhamns_moske_app/data/models/news_post.dart';
import 'package:soderhamns_moske_app/features/news/providers/news_providers.dart';
import 'package:soderhamns_moske_app/features/news/presentation/widgets/news_card.dart';
import 'package:soderhamns_moske_app/shared/providers/connectivity_provider.dart';
import 'package:soderhamns_moske_app/shared/widgets/error_view.dart';
import 'package:soderhamns_moske_app/shared/widgets/loading_view.dart';

class NewsListScreen extends ConsumerStatefulWidget {
  const NewsListScreen({super.key});

  @override
  ConsumerState<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends ConsumerState<NewsListScreen> {
  Future<void> _refresh() async {
    ref.invalidate(newsListProvider);
    await ref.read(newsListProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final newsAsync = ref.watch(newsListProvider);
    final isOnline = ref.watch(connectivityProvider).valueOrNull ?? true;
    final lastUpdated = ref.read(newsRepositoryProvider).getLastUpdated();

    return Scaffold(
      appBar: AppBar(title: const Text('Nyheter')),
      body: newsAsync.when(
        loading: () => _buildLoading(),
        error: (error, _) => _buildError(),
        data: (posts) {
          final sorted = List<NewsPost>.from(posts)
            ..sort((a, b) => b.date.compareTo(a.date));

          return Column(
            children: [
              if (!isOnline && lastUpdated != null)
                _buildOfflineBanner(lastUpdated),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: sorted.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: const Center(
                                child: Text('Inga nyheter än'),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                          itemCount: sorted.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final post = sorted[index];
                            return NewsCard(
                              post: post,
                              onTap: () =>
                                  context.go('/nyheter/${post.slug}'),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            child: SizedBox(
              height: 100,
              child: Center(
                child: LoadingView(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOfflineBanner(String lastUpdated) {
    final formatted = _formatLastUpdated(lastUpdated);
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: colors.errorContainer,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(
              Icons.cloud_off,
              size: 16,
              color: colors.onErrorContainer,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visar sparad version',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colors.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Senast uppdaterad: $formatted',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onErrorContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastUpdated(String iso) {
    try {
      final date = DateTime.parse(iso);
      return DateFormat('d MMMM y', 'sv').format(date);
    } catch (_) {
      return iso;
    }
  }

  Widget _buildError() {
    return Center(
      child: ErrorView(
        message: 'Kunde inte ladda nyheter',
        onRetry: () => ref.invalidate(newsListProvider),
      ),
    );
  }
}
