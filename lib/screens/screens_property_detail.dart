import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models_property.dart';
import '../../utils/utils_phone_utils.dart';
import '../../utils/utils_html_helper.dart';
import '../../utils/utils_mortgage_calculator.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool _isFavorite = false;
  bool _isLoadingFavorite = false;

  // AI Insights variables
  late String _hargaRata;
  late String _fasilitasTerdekat;
  late String _fasilitasDekorasi;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    _initializeAIInsights();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteProperties =
          prefs.getStringList('favorite_properties') ?? [];
      setState(() {
        _isFavorite = favoriteProperties.contains(
          widget.property.idProperty.toString(),
        );
      });
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoadingFavorite) return;

    setState(() {
      _isLoadingFavorite = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteProperties =
          prefs.getStringList('favorite_properties') ?? [];
      final propertyId = widget.property.idProperty.toString();

      if (_isFavorite) {
        // Remove from favorites
        favoriteProperties.remove(propertyId);
        setState(() {
          _isFavorite = false;
        });
      } else {
        // Add to favorites
        favoriteProperties.add(propertyId);
        setState(() {
          _isFavorite = true;
        });
      }

      await prefs.setStringList('favorite_properties', favoriteProperties);

      // Show feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite ? 'Ditambahkan ke favorit' : 'Dihapus dari favorit',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan, silakan coba lagi')),
        );
      }
    } finally {
      setState(() {
        _isLoadingFavorite = false;
      });
    }
  }

  Future<void> _shareProperty() async {
    try {
      final shareText =
          '''
🏠 ${widget.property.namaProperty}

💰 Harga: ${widget.property.formattedPrice}
📍 Lokasi: ${widget.property.alamat}
📏 Luas: ${widget.property.lt}m² (LT) / ${widget.property.lb}m² (LB)
🛏️ Kamar Tidur: ${widget.property.kamarTidur}
🚿 Kamar Mandi: ${widget.property.kamarMandi}
📋 Sertifikat: ${widget.property.surat ?? '-'}

Lihat detail selengkapnya di aplikasi Waisaka Property!

${widget.property.mainImageUrl ?? ''}
      ''';

      await Share.share(
        shareText.trim(),
        subject: widget.property.namaProperty,
      );
    } catch (e) {
      debugPrint('Error sharing property: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan saat membagikan properti'),
          ),
        );
      }
    }
  }

  void _initializeAIInsights() {
    setState(() {
      _hargaRata = widget.property.hargaRata ?? '';
      _fasilitasTerdekat = widget.property.fasilitasTerdekat ?? '';
      _fasilitasDekorasi = widget.property.fasilitasDekorasi ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.property.mainImageUrl ??
                        'https://via.placeholder.com/400x300',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: _isLoadingFavorite
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                      ),
                onPressed: _toggleFavorite,
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: _shareProperty,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.property.formattedPrice,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A237E),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.property.tipeDisplay == 'Dijual'
                              ? Colors.orange
                              : Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.property.tipeDisplay,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.property.namaProperty,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.property.alamat,
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSpecsGrid(),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  Text(
                    'Deskripsi',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // HTML Content Rendering
                  HtmlUtils.renderHtmlContent(
                    widget.property.isi ?? 'Tidak ada deskripsi',
                    fontSize: 14,
                    textColor: Colors.grey[800],
                    onLinkTap: (url) async {
                      if (url.isNotEmpty) {
                        final uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  // AI Waisaka Insight Section
                  _buildAIInsightSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
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
        child: Row(
          children: [
            // Call Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (widget.property.teleponStaff != null) {
                    final messenger = ScaffoldMessenger.of(context);
                    final success = await PhoneUtils.makePhoneCall(
                      widget.property.teleponStaff!,
                    );
                    if (!success && mounted) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Tidak dapat melakukan panggilan telepon',
                          ),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nomor telepon agen tidak tersedia'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.call, color: Colors.white),
                label: Text(
                  'Panggil',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // WhatsApp Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (widget.property.teleponStaff != null) {
                    final messenger = ScaffoldMessenger.of(context);
                    final success = await PhoneUtils.openWhatsAppForProperty(
                      widget.property.teleponStaff!,
                      propertyName: widget.property.namaProperty,
                      propertyPrice: widget.property.formattedPrice,
                      propertyAddress: widget.property.alamat,
                    );
                    if (!success && mounted) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Tidak dapat membuka WhatsApp'),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nomor telepon agen tidak tersedia'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.chat, color: Colors.white),
                label: Text(
                  'WhatsApp',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 2.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildSpecItem(
          Icons.square_foot,
          '${widget.property.lt ?? 0}m²',
          'Luas Tanah',
        ),
        _buildSpecItem(
          Icons.home_outlined,
          '${widget.property.lb ?? 0}m²',
          'Luas Bangunan',
        ),
        _buildSpecItem(
          Icons.bed_outlined,
          '${widget.property.kamarTidur ?? 0}',
          'Kamar Tidur',
        ),
        _buildSpecItem(
          Icons.bathtub_outlined,
          '${widget.property.kamarMandi ?? 0}',
          'Kamar Mandi',
        ),
        _buildSpecItem(
          Icons.layers_outlined,
          '${widget.property.lantai ?? 1}',
          'Lantai',
        ),
        _buildSpecItem(
          Icons.description_outlined,
          widget.property.surat ?? '-',
          'Sertifikat',
        ),
      ],
    );
  }

  Widget _buildSpecItem(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1A237E)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Color(0xFF1A237E),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Waisaka Insight',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                  Text(
                    'Analisis cerdas properti ini',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_hargaRata.isNotEmpty ||
              _fasilitasTerdekat.isNotEmpty ||
              _fasilitasDekorasi.isNotEmpty ||
              widget.property.petaMap != null)
            _buildEnhancedAIInsightCards()
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AI Insight sedang memproses data untuk properti ini. Silakan cek kembali nanti.',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancedAIInsightCards() {
    return Column(
      children: [
        // Harga Rata-rata Card
        if (_hargaRata.isNotEmpty)
          _buildInsightCard(
            icon: Icons.analytics_outlined,
            title: 'Analisis Harga Pasar',
            content: _hargaRata,
            color: const Color(0xFFE65100),
            accentColor: const Color(0xFFFFF3E0),
          ),

        // Fasilitas Terdekat Card
        if (_fasilitasTerdekat.isNotEmpty)
          _buildInsightCard(
            icon: Icons.map_outlined,
            title: 'Fasilitas Sekitar',
            content: _fasilitasTerdekat,
            color: const Color(0xFF1565C0),
            accentColor: const Color(0xFFE3F2FD),
          ),

        // Inspirasi Dekorasi Card
        if (_fasilitasDekorasi.isNotEmpty)
          _buildInsightCard(
            icon: Icons.palette_outlined,
            title: 'Inspirasi Dekorasi',
            content: _fasilitasDekorasi,
            color: const Color(0xFF2E7D32),
            accentColor: const Color(0xFFE8F5E9),
          ),
      ],
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    required Color accentColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: const Color(0xFF333333),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: HtmlUtils.renderHtmlContent(
                content,
                fontSize: 14,
                textColor: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KprCalculatorBottomSheet extends StatefulWidget {
  final double propertyPrice;
  final String propertyName;

  const KprCalculatorBottomSheet({
    super.key,
    required this.propertyPrice,
    required this.propertyName,
  });

  @override
  State<KprCalculatorBottomSheet> createState() =>
      _KprCalculatorBottomSheetState();
}

class _KprCalculatorBottomSheetState extends State<KprCalculatorBottomSheet> {
  double _downPaymentPercent = 20;
  double _interestRate = 11.5;
  int _loanTenure = 20;
  double _monthlyIncome = 10000000;
  bool _showSchedule = false;

  late MortgageCalculator _calculator;

  @override
  void initState() {
    super.initState();
    _updateCalculator();
  }

  void _updateCalculator() {
    _calculator = MortgageCalculator(
      propertyPrice: widget.propertyPrice,
      downPaymentPercent: _downPaymentPercent,
      annualInterestRate: _interestRate,
      loanTenureYears: _loanTenure,
    );
  }

  @override
  Widget build(BuildContext context) {
    final affordability = _calculator.getAffordabilityAnalysis(_monthlyIncome);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        'Kalkulator KPR',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.propertyName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Harga Properti',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(widget.propertyPrice),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A237E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Down Payment Slider
                  _buildSliderSection(
                    'Uang Muka (${_downPaymentPercent.toInt()}%)',
                    _downPaymentPercent,
                    5,
                    50,
                    (value) {
                      setState(() {
                        _downPaymentPercent = value;
                        _updateCalculator();
                      });
                    },
                    subtitle: NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(_calculator.downPayment),
                  ),
                  const SizedBox(height: 20),

                  // Interest Rate Slider
                  _buildSliderSection(
                    'Suku Bunga (${_interestRate.toStringAsFixed(1)}%)',
                    _interestRate,
                    5,
                    15,
                    (value) {
                      setState(() {
                        _interestRate = value;
                        _updateCalculator();
                      });
                    },
                    subtitle: 'Tahunan',
                  ),
                  const SizedBox(height: 20),

                  // Loan Tenure Slider
                  _buildSliderSection(
                    'Tenor $_loanTenure tahun',
                    _loanTenure.toDouble(),
                    5,
                    30,
                    (value) {
                      setState(() {
                        _loanTenure = value.round();
                        _updateCalculator();
                      });
                    },
                    subtitle: 'Jangka waktu pinjaman',
                  ),
                  const SizedBox(height: 20),

                  // Monthly Income Input
                  _buildIncomeSection(),
                  const SizedBox(height: 20),

                  // Results
                  _buildResultsSection(affordability),
                  const SizedBox(height: 20),

                  // Payment Schedule Toggle
                  _buildScheduleToggle(),
                  if (_showSchedule) ...[
                    const SizedBox(height: 20),
                    _buildPaymentSchedule(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSection(
    String title,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) / 0.5).round(),
          activeColor: const Color(0xFF1A237E),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildIncomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Penghasilan Bulanan',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Masukkan penghasilan bulanan',
            prefixText: 'Rp ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1A237E)),
            ),
          ),
          onChanged: (value) {
            final income = double.tryParse(
              value.replaceAll(RegExp(r'[^0-9]'), ''),
            );
            if (income != null) {
              setState(() {
                _monthlyIncome = income;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildResultsSection(AffordabilityAnalysis affordability) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A237E).withValues(alpha: 0.1),
            const Color(0xFF3949AB).withValues(alpha: 0.1),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1A237E).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hasil Perhitungan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 12),
          _buildResultRow('Plafon Pinjaman', _calculator.loanAmount),
          _buildResultRow('Cicilan Bulanan', _calculator.fixedRatePayment),
          _buildResultRow('Total Bunga', _calculator.totalInterest),
          _buildResultRow('Total Pembayaran', _calculator.totalPayment),
          const SizedBox(height: 12),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                affordability.isAffordable ? Icons.check_circle : Icons.warning,
                color: affordability.ratioColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rasio DTI: ${affordability.debtToIncomeRatio.toStringAsFixed(1)}%',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: affordability.ratioColor,
                      ),
                    ),
                    Text(
                      affordability.ratioStatus,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: affordability.ratioColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
          Text(
            NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(amount),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A237E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleToggle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tampilkan Jadwal Angsuran',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: _showSchedule,
                onChanged: (value) {
                  setState(() {
                    _showSchedule = value;
                  });
                },
                activeThumbColor: const Color(0xFF1A237E),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSchedule() {
    final schedule = _calculator.generatePaymentSchedule();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Bulan',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Angsuran',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Pokok',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Bunga',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Sisa',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // Schedule Items (show first 12 months)
          ...schedule
              .take(12)
              .map(
                (payment) => Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: payment.isFixedRate
                        ? Colors.blue.withValues(alpha: 0.05)
                        : Colors.transparent,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          payment.month.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: payment.isFixedRate
                                ? const Color(0xFF1A237E)
                                : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          payment.formattedPayment,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: payment.isFixedRate
                                ? const Color(0xFF1A237E)
                                : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          payment.formattedPrincipal,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: payment.isFixedRate
                                ? const Color(0xFF1A237E)
                                : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          payment.formattedInterest,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: payment.isFixedRate
                                ? const Color(0xFF1A237E)
                                : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          payment.formattedBalance,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: payment.isFixedRate
                                ? const Color(0xFF1A237E)
                                : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          // Show more indicator
          if (schedule.length > 12)
            Container(
              padding: const EdgeInsets.all(12),
              child: Text(
                '... ${schedule.length - 12} bulan tersisa',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
