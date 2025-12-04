import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/management_article.dart';
import '../widgets/article_card.dart';

class AllArticlesWidget extends StatefulWidget {
  final String? title;
  final bool enableSearch;
  final bool enablePullToRefresh;

  const AllArticlesWidget({
    super.key,
    this.title = 'Semua Artikel',
    this.enableSearch = true,
    this.enablePullToRefresh = true,
  });

  @override
  State<AllArticlesWidget> createState() => _AllArticlesWidgetState();
}

class _AllArticlesWidgetState extends State<AllArticlesWidget> {
  late ArticleProvider _articleProvider;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _articleProvider = Provider.of<ArticleProvider>(context, listen: false);
    _loadArticles();

    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadArticles({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
    }

    if (_isSearching) {
      await _articleProvider.searchArticles(
        _searchController.text.trim(),
        page: _currentPage,
      );
    } else {
      await _articleProvider.loadArticles(page: _currentPage, limit: 10);
    }
  }

  Future<void> _loadMoreArticles() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      if (_isSearching) {
        await _articleProvider.searchArticles(
          _searchController.text.trim(),
          page: _currentPage,
        );
      } else {
        await _articleProvider.loadArticles(page: _currentPage, limit: 10);
      }
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 200 && !_isLoadingMore) {
      _loadMoreArticles();
    }
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
      });
      _loadArticles(refresh: true);
    } else {
      setState(() {
        _isSearching = true;
        _currentPage = 1;
      });
      _loadArticles();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
    _loadArticles(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  widget.title!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),

        // Search Bar
        if (widget.enableSearch)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Cari artikel...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.clear, color: Color(0xFF9CA3AF)),
                  ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Articles List
        Expanded(
          child: Consumer<ArticleProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && !provider.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.hasError && !provider.hasData) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[400],
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.errorMessage,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadArticles,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (!provider.hasData) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          color: Colors.grey[400],
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isSearching
                              ? 'Tidak ada artikel ditemukan untuk "${_searchController.text}"'
                              : 'Belum ada artikel tersedia',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_isSearching)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: ElevatedButton(
                              onPressed: _clearSearch,
                              child: const Text('Hapus Pencarian'),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await _loadArticles(refresh: true);
                },
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount:
                      provider.articles.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.articles.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final article = provider.articles[index];
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
              );
            },
          ),
        ),
      ],
    );
  }
}
