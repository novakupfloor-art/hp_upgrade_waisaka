import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import 'config/auth_routes.dart';
import 'providers/management_property.dart';
import 'providers/management_article.dart';
import 'screens/screens_login.dart';
import 'screens/screens_register.dart';
import 'screens/screens_property_detail.dart';
import 'screens/screens_search.dart';
import 'models/models_user.dart';
import 'screens/screens_dashboard.dart';
import 'widgets/data_widgets.dart';
import 'widgets/ai_search_widget.dart';
import 'screens/screens_article_detail.dart';

class ScreensDefault extends StatefulWidget {
  const ScreensDefault({super.key});

  @override
  State<ScreensDefault> createState() => _ScreensDefaultState();
}

class _ScreensDefaultState extends State<ScreensDefault> {
  User? _currentUser;
  String _selectedListingType = 'jual'; // Default to 'jual'
  final GlobalKey<AiSearchWidgetState> _aiSearchKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadUser();
    // Load data using Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().loadProperties(
        listingType: _selectedListingType,
      );
      context.read<ArticleProvider>().loadArticles();
    });
  }

  Future<void> _loadUser() async {
    final user = await AuthRoutes.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  Future<void> _refreshData() async {
    await Future.wait([
      context.read<PropertyProvider>().refreshProperties(
        listingType: _selectedListingType,
      ),
      context.read<ArticleProvider>().refreshArticles(),
    ]);
    await _loadUser();
  }

  void _handleListingTypeChange(String type) {
    setState(() => _selectedListingType = type);

    // Navigate to All Properties Screen with the selected type
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllPropertiesScreen(initialListingType: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light Grey Background
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroSection(),
              _buildSearchFilterSection(), // AI Search Widget Section
              const SizedBox(height: 24),
              _buildSectionHeader('Properti Terbaru', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllPropertiesScreen(),
                  ),
                );
              }),
              _buildPropertyTabs(),
              const SizedBox(height: 16),
              _buildHorizontalPropertyList(),
              const SizedBox(height: 24),
              _buildSectionHeader('Artikel Terbaru', () {}),
              _buildHorizontalArticleList(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E), // Primary Blue
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.home_work, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            'WaisakaProperty',
            style: GoogleFonts.poppins(
              color: const Color(0xFF1A237E),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        if (_currentUser != null) ...[
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardScreen(user: _currentUser!),
                ),
              );
            },
            icon: const Icon(Icons.dashboard, color: Color(0xFF1A237E)),
            label: Text(
              'Dashboard',
              style: GoogleFonts.poppins(
                color: const Color(0xFF1A237E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 20),
        ] else ...[
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: Text(
              'Login',
              style: GoogleFonts.poppins(
                color: const Color(0xFF1A237E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
            child: Text(
              'Sign Up',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      height: 180,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80',
          ),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(20),
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temukan Hunian Impian',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Ribuan properti terbaik menunggu Anda',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AiSearchWidget(
        key: _aiSearchKey,
        initialListingType: 'jual',
        onSearchStarted: () {
          // Optional: Show loading indicator
        },
        onListingTypeChanged: (type) {
          if (_selectedListingType != type) {
            setState(() {
              _selectedListingType = type;
            });
            // If search is NOT active, we might want to reload default properties
            // But if search IS active, the widget handles it.
            // We can check if we need to reload default list:
            if (!(_aiSearchKey.currentState?.hasActiveSearch ?? false)) {
              context.read<PropertyProvider>().loadProperties(
                listingType: _selectedListingType,
              );
            }
          }
        },
        // Navigate to All Properties screen when search is performed
        onNavigateToResults: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AllPropertiesScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'Lihat Semua',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A237E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalPropertyList() {
    return _PaginatedPropertyList(listingType: _selectedListingType);
  }

  Widget _buildHorizontalArticleList() {
    return DataArticle(
      builder: (context, dataArticleWidgets, child) {
        if (dataArticleWidgets.isLoading) {
          return const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (dataArticleWidgets.hasError) {
          return SizedBox(
            height: 220,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Gagal memuat artikel',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                  TextButton(
                    onPressed: () => dataArticleWidgets.refreshArticles(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        } else if (!dataArticleWidgets.hasData) {
          return SizedBox(
            height: 220,
            child: Center(
              child: Text(
                'Belum ada artikel',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
          );
        }

        final articles = dataArticleWidgets.articles;
        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ArticleDetailScreen(article: article),
                    ),
                  );
                },
                child: Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl:
                              article.articleImages ??
                              'https://via.placeholder.com/280x120',
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(height: 120, color: Colors.white),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 120,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.judulBerita,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF333333),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPropertyTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildTabButton('jual', 'Dijual'),
          const SizedBox(width: 12),
          _buildTabButton('sewa', 'Disewa'),
        ],
      ),
    );
  }

  Widget _buildTabButton(String type, String label) {
    final isSelected = _selectedListingType == type;
    return GestureDetector(
      onTap: () => _handleListingTypeChange(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A237E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1A237E).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// Stateful widget for paginated horizontal property list
class _PaginatedPropertyList extends StatefulWidget {
  final String listingType;

  const _PaginatedPropertyList({required this.listingType});

  @override
  State<_PaginatedPropertyList> createState() => _PaginatedPropertyListState();
}

class _PaginatedPropertyListState extends State<_PaginatedPropertyList> {
  final ScrollController _scrollController = ScrollController();
  static const double _itemWidth = 236.0; // 220 width + 16 margin

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      // Force rebuild to update arrow buttons state
      setState(() {});
    }
  }

  void _scrollLeft() {
    if (!_scrollController.hasClients) return;
    final currentOffset = _scrollController.offset;
    final currentIndex = (currentOffset / _itemWidth).ceil();
    if (currentIndex > 0) {
      _scrollController.animateTo(
        (currentIndex - 1) * _itemWidth,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollRight() {
    if (!_scrollController.hasClients) return;
    final currentOffset = _scrollController.offset;
    final currentIndex = (currentOffset / _itemWidth).floor();
    _scrollController.animateTo(
      (currentIndex + 1) * _itemWidth,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // _loadNextPage removed to disable infinite scroll

  @override
  Widget build(BuildContext context) {
    return DataIklanProperty(
      builder: (context, dataPropertyWidgets, child) {
        // Debug logging
        debugPrint('🏠 Property Widget State:');
        debugPrint('  - isLoading: ${dataPropertyWidgets.isLoading}');
        debugPrint('  - hasError: ${dataPropertyWidgets.hasError}');
        debugPrint('  - hasData: ${dataPropertyWidgets.hasData}');
        debugPrint(
          '  - properties count: ${dataPropertyWidgets.properties.length}',
        );
        if (dataPropertyWidgets.hasError) {
          debugPrint('  - error: ${dataPropertyWidgets.errorMessage}');
        }

        if (dataPropertyWidgets.isLoading) {
          return const SizedBox(
            height: 280,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (dataPropertyWidgets.hasError) {
          return SizedBox(
            height: 280,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Gagal memuat properti',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                  TextButton(
                    onPressed: () {
                      dataPropertyWidgets.refreshProperties(
                        listingType: widget.listingType,
                      );
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        } else if (!dataPropertyWidgets.hasData) {
          return const SizedBox(
            height: 280,
            child: Center(child: Text('Tidak ada properti ditemukan')),
          );
        }

        final properties = dataPropertyWidgets.properties;

        // Calculate visibility safely
        bool canScrollLeft = false;
        bool canScrollRight = false;

        if (_scrollController.hasClients) {
          canScrollLeft = _scrollController.offset > 5; // Small tolerance
          final maxScroll = _scrollController.position.maxScrollExtent;
          final currentScroll = _scrollController.offset;
          // If we are not at the end, we can scroll right
          canScrollRight = currentScroll < maxScroll - 5;
        } else {
          // Initial state: assume we can scroll right if there are many items
          canScrollRight = properties.length > 2;
        }

        return SizedBox(
          height: 280,
          child: Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final item = properties[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PropertyDetailScreen(property: item),
                        ),
                      );
                    },
                    child: Container(
                      width: 220,
                      margin: const EdgeInsets.only(right: 16, bottom: 10),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: CachedNetworkImage(
                              imageUrl:
                                  item.mainImageUrl ??
                                  'https://via.placeholder.com/400x200',
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  height: 140,
                                  color: Colors.white,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 140,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.formattedPrice,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1A237E),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: item.tipeDisplay == 'Dijual'
                                            ? Colors.orange.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.blue.withValues(
                                                alpha: 0.1,
                                              ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item.tipeDisplay,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: item.tipeDisplay == 'Dijual'
                                              ? Colors.orange
                                              : Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.namaProperty,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF333333),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 12,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        item.alamat,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    if (item.kamarTidur != null) ...[
                                      const Icon(
                                        Icons.bed_outlined,
                                        size: 12,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${item.kamarTidur}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    if (item.kamarMandi != null) ...[
                                      const Icon(
                                        Icons.bathtub_outlined,
                                        size: 12,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${item.kamarMandi}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    if (item.lt != null) ...[
                                      const Icon(
                                        Icons.square_foot,
                                        size: 12,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${item.lt}m²',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Left Arrow
              if (canScrollLeft)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                        color: const Color(0xFF1A237E),
                        onPressed: _scrollLeft,
                      ),
                    ),
                  ),
                ),
              // Right Arrow
              if (canScrollRight)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 18),
                        color: const Color(0xFF1A237E),
                        onPressed: _scrollRight,
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
