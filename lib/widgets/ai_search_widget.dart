import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/management_property.dart';

/// AI-powered search widget with voice input and advanced filters
class AiSearchWidget extends StatefulWidget {
  final String? initialListingType;
  final VoidCallback? onSearchStarted;
  final Function(List)? onResultsReceived;
  final Function(String)? onListingTypeChanged;
  final VoidCallback? onNavigateToResults; // New callback for navigation

  const AiSearchWidget({
    super.key,
    this.initialListingType,
    this.onSearchStarted,
    this.onResultsReceived,
    this.onListingTypeChanged,
    this.onNavigateToResults, // Add to constructor
    this.onAiSearch,
    this.onRegularSearch,
  });

  final Future<void> Function({
    required String listingType,
    String? keywords,
    String? location,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    int? bathrooms,
    String? propertyType,
    String? certificate,
    double? minLandArea,
    double? maxLandArea,
    double? minBuildingArea,
    double? maxBuildingArea,
  })?
  onAiSearch;

  final Future<void> Function({
    String? keyword,
    String? listingType,
    String? location,
    String? priceFrom,
    String? priceTo,
    String? bedrooms,
    String? bathrooms,
    String? buildingSizeFrom,
    String? buildingSizeTo,
    String? landSizeFrom,
    String? landSizeTo,
  })?
  onRegularSearch;

  @override
  State<AiSearchWidget> createState() => AiSearchWidgetState();
}

class AiSearchWidgetState extends State<AiSearchWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _selectedListingType = 'jual';
  bool _useAiSearch = true; // Toggle for AI vs regular search

  // Filter values
  double? _minPrice;
  double? _maxPrice;
  String? _bedrooms;
  String? _bathrooms;
  String? _location;
  int? _minBuildingArea; // Luas bangunan minimum
  int? _maxBuildingArea; // Luas bangunan maximum
  int? _minLandArea; // Luas tanah minimum
  int? _maxLandArea; // Luas tanah maximum

  // Controllers for Reset functionality
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  late TextEditingController _minLandAreaController;
  late TextEditingController _maxLandAreaController;
  late TextEditingController _minBuildingAreaController;
  late TextEditingController _maxBuildingAreaController;
  late TextEditingController _locationController;
  late TextEditingController _bedroomsController;
  late TextEditingController _bathroomsController;

  bool get hasActiveSearch =>
      _searchController.text.isNotEmpty || _hasActiveFilters();

  void searchWithNewType(String type) {
    setState(() {
      _selectedListingType = type;
    });
    _performSearch();
  }

  void updateTypeSilently(String type) {
    if (_selectedListingType != type) {
      setState(() {
        _selectedListingType = type;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedListingType = widget.initialListingType ?? 'jual';

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    // Initialize controllers
    _minPriceController = TextEditingController();
    _maxPriceController = TextEditingController();
    _minLandAreaController = TextEditingController();
    _maxLandAreaController = TextEditingController();
    _minBuildingAreaController = TextEditingController();
    _maxBuildingAreaController = TextEditingController();
    _locationController = TextEditingController();
    _bedroomsController = TextEditingController();
    _bathroomsController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minLandAreaController.dispose();
    _maxLandAreaController.dispose();
    _minBuildingAreaController.dispose();
    _maxBuildingAreaController.dispose();
    _locationController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty && !_hasActiveFilters()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan kata kunci atau pilih filter'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    widget.onSearchStarted?.call();

    final provider = Provider.of<PropertyProvider>(context, listen: false);

    if (_useAiSearch) {
      // Show AI loading overlay
      _showAiLoadingOverlay();

      try {
        if (widget.onAiSearch != null) {
          await widget.onAiSearch!(
            listingType: _selectedListingType,
            keywords: query.isNotEmpty ? query : null,
            location: null,
            minPrice: null,
            maxPrice: null,
            bedrooms: null,
            bathrooms: null,
            minLandArea: null,
            maxLandArea: null,
            minBuildingArea: null,
            maxBuildingArea: null,
          );
        } else {
          // In AI Mode, we ignore manual filters and let AI parse the query
          await provider.searchWithAi(
            listingType: _selectedListingType,
            keywords: query.isNotEmpty ? query : null,
            // Explicitly set other filters to null so backend relies on AI parsing
            location: null,
            minPrice: null,
            maxPrice: null,
            bedrooms: null,
            bathrooms: null,
            minLandArea: null,
            maxLandArea: null,
            minBuildingArea: null,
            maxBuildingArea: null,
          );
        }
      } finally {
        // Hide loading overlay
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } else {
      // Use regular filter search

      // Show basic loading (less fancy than AI)
      _showRegularLoadingOverlay();

      try {
        // Handle Area Filters for Regular Search
        int? minLand = _minLandArea;
        int? maxLand = _maxLandArea;
        if (minLand != null && maxLand == null) maxLand = 1000000;
        if (maxLand != null && minLand == null) minLand = 0;

        int? minBuild = _minBuildingArea;
        int? maxBuild = _maxBuildingArea;
        if (minBuild != null && maxBuild == null) maxBuild = 1000000;
        if (maxBuild != null && minBuild == null) minBuild = 0;

        if (widget.onRegularSearch != null) {
          await widget.onRegularSearch!(
            keyword: query.isNotEmpty ? query : null,
            listingType: _selectedListingType,
            location: _location,
            priceFrom: _minPrice?.toString(),
            priceTo: _maxPrice?.toString(),
            bedrooms: _bedrooms,
            bathrooms: _bathrooms,
            buildingSizeFrom: minBuild?.toString(),
            buildingSizeTo: maxBuild?.toString(),
            landSizeFrom: minLand?.toString(),
            landSizeTo: maxLand?.toString(),
          );
        } else {
          provider.searchPropertiesWithFilters(
            keyword: query.isNotEmpty ? query : null,
            listingType: _selectedListingType,
            location: _location,
            priceFrom: _minPrice?.toString(),
            priceTo: _maxPrice?.toString(),
            bedrooms: _bedrooms,
            bathrooms: _bathrooms,
            buildingSizeFrom: minBuild?.toString(),
            buildingSizeTo: maxBuild?.toString(),
            landSizeFrom: minLand?.toString(),
            landSizeTo: maxLand?.toString(),
          );
        }
      } finally {
        // Hide loading overlay
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    }

    // Trigger navigation to results screen if callback is provided
    widget.onNavigateToResults?.call();
  }

  void _showAiLoadingOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false, // Prevent dismissal
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // AI Icon with pulsing animation
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.2),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF1A237E,
                            ).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.psychology,
                            size: 48,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      );
                    },
                    onEnd: () {
                      // Restart animation if still mounted
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Title
                  const Text(
                    'AI Waisaka Sedang Bekerja',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Description
                  const Text(
                    'Menganalisis pencarian Anda dan mencari properti terbaik di database...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Loading indicator
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF1A237E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Processing steps
                  _buildProcessingStep('🤖 Memahami query Anda', true),
                  const SizedBox(height: 8),
                  _buildProcessingStep('🔍 Mencari di database', true),
                  const SizedBox(height: 8),
                  _buildProcessingStep('✨ Menyusun hasil terbaik', true),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProcessingStep(String text, bool isActive) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isActive)
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF1A237E).withValues(alpha: 0.5),
              ),
            ),
          )
        else
          Icon(
            Icons.check_circle,
            size: 12,
            color: Colors.green.withValues(alpha: 0.5),
          ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? const Color(0xFF1A237E) : const Color(0xFF999999),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  void _showRegularLoadingOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Simple grey circular progress
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Plain text
                  const Text(
                    'Mencari...',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),

                  // Subtle hint to use AI
                  Text(
                    'Tip: Gunakan AI Search untuk hasil lebih cepat',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAdvancedFiltersSheet(),
    );
  }

  Widget _buildAdvancedFiltersSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _performSearch();
                      },
                      child: const Text('Cari'),
                    ),
                    const Text(
                      'Filter Pencarian',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _minPrice = null;
                          _maxPrice = null;
                          _bedrooms = null;
                          _bathrooms = null;
                          _location = null;
                          _minBuildingArea = null;
                          _maxBuildingArea = null;
                          _minLandArea = null;
                          _maxLandArea = null;

                          // Clear controllers
                          _minPriceController.clear();
                          _maxPriceController.clear();
                          _minLandAreaController.clear();
                          _maxLandAreaController.clear();
                          _minBuildingAreaController.clear();
                          _maxBuildingAreaController.clear();
                          _locationController.clear();
                          _bedroomsController.clear();
                          _bathroomsController.clear();
                        });
                        // Navigator.pop(context); // Don't close on reset, let user choose
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Filters content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildLocationFilter(),
                    const SizedBox(height: 20),
                    _buildPriceRangeFilter(),
                    const SizedBox(height: 20),
                    _buildBuildingAreaFilter(),
                    const SizedBox(height: 20),
                    _buildLandAreaFilter(),
                    const SizedBox(height: 20),
                    _buildBedroomsFilter(),
                    const SizedBox(height: 20),
                    _buildBathroomsFilter(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // Apply button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _performSearch();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Terapkan Filter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

  Widget _buildLocationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lokasi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: 'Cth: Bandung, Jakarta Selatan',
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          onChanged: (value) => _location = value.isEmpty ? null : value,
        ),
      ],
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rentang Harga',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minPriceController,
                decoration: InputDecoration(
                  hintText: 'Min',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  _minPrice = double.tryParse(value);
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('-', style: TextStyle(fontSize: 18)),
            ),
            Expanded(
              child: TextField(
                controller: _maxPriceController,
                decoration: InputDecoration(
                  hintText: 'Max',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  _maxPrice = double.tryParse(value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBuildingAreaFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Luas Bangunan (m²)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minBuildingAreaController,
                decoration: InputDecoration(
                  hintText: 'Min',
                  prefixIcon: const Icon(Icons.home_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  _minBuildingArea = value.isEmpty ? null : int.tryParse(value);
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('-', style: TextStyle(fontSize: 18)),
            ),
            Expanded(
              child: TextField(
                controller: _maxBuildingAreaController,
                decoration: InputDecoration(
                  hintText: 'Max',
                  prefixIcon: const Icon(Icons.home_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  _maxBuildingArea = value.isEmpty ? null : int.tryParse(value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLandAreaFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Luas Tanah (m²)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minLandAreaController,
                decoration: InputDecoration(
                  hintText: 'Min',
                  prefixIcon: const Icon(Icons.landscape_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  _minLandArea = value.isEmpty ? null : int.tryParse(value);
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('-', style: TextStyle(fontSize: 18)),
            ),
            Expanded(
              child: TextField(
                controller: _maxLandAreaController,
                decoration: InputDecoration(
                  hintText: 'Max',
                  prefixIcon: const Icon(Icons.landscape_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  _maxLandArea = value.isEmpty ? null : int.tryParse(value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBedroomsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kamar Tidur',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _bedroomsController,
          decoration: InputDecoration(
            hintText: 'Jumlah Kamar Tidur',
            prefixIcon: const Icon(Icons.bed_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            _bedrooms = value.isEmpty ? null : value;
          },
        ),
      ],
    );
  }

  Widget _buildBathroomsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kamar Mandi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _bathroomsController,
          decoration: InputDecoration(
            hintText: 'Jumlah Kamar Mandi',
            prefixIcon: const Icon(Icons.bathtub_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            _bathrooms = value.isEmpty ? null : value;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A237E),
              const Color(0xFF1A237E).withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A237E).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Toggle and Powered By text
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // AI Search Toggle
                Row(
                  children: [
                    Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        value: _useAiSearch,
                        onChanged: (value) {
                          setState(() => _useAiSearch = value);
                        },
                        activeThumbColor: Colors.white,
                        activeTrackColor: const Color(0xFF5C6BC0),
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey.withValues(alpha: 0.5),
                        trackOutlineColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'AI Search',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Container(
                  width: 1,
                  height: 16,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 12),
                Text(
                  'Powered by Waisaka AI',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Listing type selector
            Row(
              children: [
                Expanded(child: _buildListingTypeButton('jual', 'Dijual')),
                const SizedBox(width: 12),
                Expanded(child: _buildListingTypeButton('sewa', 'Disewa')),
              ],
            ),

            const SizedBox(height: 16),

            // Search field
            Container(
              decoration: BoxDecoration(
                color: _useAiSearch ? const Color(0xFFE8EAF6) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: _useAiSearch
                      ? 'Cari properti impian Anda dengan AI...'
                      : 'Cari berdasarkan lokasi, nama...',
                  hintStyle: TextStyle(
                    color: _useAiSearch
                        ? const Color(0xFF1A237E).withValues(alpha: 0.7)
                        : Colors.grey[400],
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF1A237E),
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_useAiSearch)
                        IconButton(
                          icon: Icon(
                            Icons.tune,
                            color: _hasActiveFilters()
                                ? const Color(0xFF1A237E)
                                : Colors.grey,
                          ),
                          onPressed: _showAdvancedFilters,
                          tooltip: 'Filter Lanjutan',
                        ),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFF1A237E),
                        ),
                        onPressed: _performSearch,
                      ),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onSubmitted: (_) => _performSearch(),
              ),
            ),

            // AI Search Example Text
            if (_useAiSearch) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Contoh: Cari rumah dijual di kota wisata dengan harga maximal 3 milyar...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],

            // Active filters indicator
            if (_hasActiveFilters()) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildActiveFilterChips(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListingTypeButton(String type, String label) {
    final isSelected = _selectedListingType == type;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _selectedListingType = type);
          if (hasActiveSearch) {
            _performSearch();
          }
          widget.onListingTypeChanged?.call(type);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF1A237E) : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _minPrice != null ||
        _maxPrice != null ||
        _bedrooms != null ||
        _bathrooms != null ||
        (_location != null && _location!.isNotEmpty) ||
        _minBuildingArea != null ||
        _maxBuildingArea != null ||
        _minLandArea != null ||
        _maxLandArea != null;
  }

  List<Widget> _buildActiveFilterChips() {
    final chips = <Widget>[];

    if (_location != null && _location!.isNotEmpty) {
      chips.add(
        _buildFilterChip('📍 $_location', () {
          setState(() {
            _location = null;
            _locationController.clear();
          });
        }),
      );
    }

    if (_minPrice != null || _maxPrice != null) {
      String priceText = 'Rp ';
      if (_minPrice != null) {
        priceText += '${(_minPrice! / 1000000).toStringAsFixed(0)}jt';
      }
      if (_minPrice != null && _maxPrice != null) {
        priceText += ' - ';
      }
      if (_maxPrice != null) {
        priceText += '${(_maxPrice! / 1000000).toStringAsFixed(0)}jt';
      }

      chips.add(
        _buildFilterChip(priceText, () {
          setState(() {
            _minPrice = null;
            _maxPrice = null;
            _minPriceController.clear();
            _maxPriceController.clear();
          });
        }),
      );
    }

    if (_bedrooms != null) {
      chips.add(
        _buildFilterChip('🛏️ $_bedrooms+ KT', () {
          setState(() => _bedrooms = null);
        }),
      );
    }

    if (_bathrooms != null) {
      chips.add(
        _buildFilterChip('🚿 $_bathrooms+ KM', () {
          setState(() => _bathrooms = null);
        }),
      );
    }

    if (_minBuildingArea != null || _maxBuildingArea != null) {
      String text = '🏠 ';
      if (_minBuildingArea != null) text += '${_minBuildingArea}m²';
      if (_minBuildingArea != null && _maxBuildingArea != null) text += ' - ';
      if (_maxBuildingArea != null) text += '${_maxBuildingArea}m²';
      chips.add(
        _buildFilterChip(text, () {
          setState(() {
            _minBuildingArea = null;
            _maxBuildingArea = null;
          });
        }),
      );
    }

    if (_minLandArea != null || _maxLandArea != null) {
      String text = '🌳 ';
      if (_minLandArea != null) text += '${_minLandArea}m²';
      if (_minLandArea != null && _maxLandArea != null) text += ' - ';
      if (_maxLandArea != null) text += '${_maxLandArea}m²';
      chips.add(
        _buildFilterChip(text, () {
          setState(() {
            _minLandArea = null;
            _maxLandArea = null;
          });
        }),
      );
    }

    return chips;
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1A237E),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 16, color: Color(0xFF1A237E)),
          ),
        ],
      ),
    );
  }
}
