import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soderhamns_moske_app/data/models/news_post.dart';
import 'package:soderhamns_moske_app/features/news/providers/news_providers.dart';
import 'package:soderhamns_moske_app/features/news/presentation/widgets/news_card.dart';
import 'package:soderhamns_moske_app/features/news/presentation/widgets/news_offline_banner.dart';
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

          final recent = sorted.where((p) => _isRecent(p.date)).toList();
          final older = sorted.where((p) => !_isRecent(p.date)).toList();

          return Column(
            children: [
              if (!isOnline && lastUpdated != null)
                NewsOfflineBanner(lastUpdated: lastUpdated),
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
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          itemCount: _itemCount(recent.length, older.length),
                          itemBuilder: (context, index) {
                            return _buildItem(index, recent, older);
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Colors.black.withValues(alpha: 0.06),
                width: 1,
              ),
            ),
            child: SizedBox(
              height: 140,
              child: Center(
                child: LoadingView(),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isRecent(DateTime date) {
    return DateTime.now().difference(date).inDays < 7;
  }

  int _itemCount(int recentCount, int olderCount) {
    var count = recentCount + olderCount;
    if (olderCount > 0) count += 1; // section header
    return count;
  }

  Widget _buildItem(int index, List<NewsPost> recent, List<NewsPost> older) {
    if (index < recent.length) {
      return NewsCard(
        post: recent[index],
        isNew: true,
        onTap: () => context.go('/nyheter/${recent[index].slug}'),
      );
    }

    final headerIndex = recent.length;
    if (older.isNotEmpty && index == headerIndex) {
      return _sectionHeader('Tidigare');
    }

    final olderIndex = index - headerIndex - 1;
    final post = older[olderIndex];
    return NewsCard(
      post: post,
      onTap: () => context.go('/nyheter/${post.slug}'),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
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
