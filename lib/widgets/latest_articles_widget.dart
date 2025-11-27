import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers_article.dart';
import 'article_card.dart';

class LatestArticlesWidget extends StatefulWidget {
  final String? title;
  final int limit;
  final bool showViewAll;
  final VoidCallback? onViewAll;

  const LatestArticlesWidget({
    super.key,
    this.title = 'Artikel Terbaru',
    this.limit = 5,
    this.showViewAll = true,
    this.onViewAll,
  });

  @override
  State<LatestArticlesWidget> createState() => _LatestArticlesWidgetState();
}

class _LatestArticlesWidgetState extends State<LatestArticlesWidget> {
  late ArticleProvider _articleProvider;

  @override
  void initState() {
    super.initState();
    _articleProvider = Provider.of<ArticleProvider>(context, listen: false);
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    await _articleProvider.loadLatestArticles(limit: widget.limit);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ArticleProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  if (widget.showViewAll && widget.onViewAll != null)
                    GestureDetector(
                      onTap: widget.onViewAll,
                      child: Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Consumer<ArticleProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && !provider.hasLatestData) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (provider.hasError && !provider.hasLatestData) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[400],
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.errorMessage,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadArticles,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                if (!provider.hasLatestData) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.article_outlined,
                          color: Colors.grey[400],
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada artikel tersedia',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Articles List
                return Column(
                  children: [
                    // Horizontal scroll for latest articles
                    SizedBox(
                      height: 240,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.latestArticles.length,
                        itemBuilder: (context, index) {
                          final article = provider.latestArticles[index];
                          return ArticleCard(
                            article: article,
                            onTap: () {
                              // Navigate to article detail
                              Navigator.pushNamed(
                                context,
                                '/article_detail',
                                arguments: article.idBerita,
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // Refresh button
                    if (provider.hasLatestData)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (provider.isLoading)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              IconButton(
                                onPressed: _loadArticles,
                                icon: Icon(
                                  Icons.refresh,
                                  color: Colors.grey[600],
                                ),
                                tooltip: 'Perbarui artikel',
                              ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
