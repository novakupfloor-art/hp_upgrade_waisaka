import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models_property.dart';
import '../models/models_user.dart';
import '../../providers/api_routes/property_routes.dart';
import 'screens_add_property.dart';
import 'screens_edit_property.dart';

class MyPropertiesScreen extends StatefulWidget {
  final User user;

  const MyPropertiesScreen({super.key, required this.user});

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  late Future<List<Property>> _propertiesFuture;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  void _loadProperties() {
    if (widget.user.staffId != null) {
      _propertiesFuture = PropertyRoutes.getMyProperties(widget.user.staffId!);
    } else {
      _propertiesFuture = Future.error('User is not a staff member');
    }
  }

  Future<void> _refreshProperties() async {
    setState(() {
      _loadProperties();
    });
  }

  Future<void> _editProperty(Property property) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPropertyScreen(property: property, user: widget.user),
      ),
    );
    if (result == true) {
      _refreshProperties();
    }
  }

  Future<void> _deleteProperty(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Properti'),
        content: const Text('Apakah Anda yakin ingin menghapus properti ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await PropertyRoutes.deleteProperty(id);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Properti berhasil dihapus')),
          );
          _refreshProperties();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus properti')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Properti Saya',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPropertyScreen(user: widget.user)),
          );
          if (result == true) {
            _refreshProperties();
          }
        },
        backgroundColor: const Color(0xFF1A237E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: widget.user.staffId == null
          ? Center(
              child: Text('Anda bukan staff', style: GoogleFonts.poppins()),
            )
          : FutureBuilder<List<Property>>(
              future: _propertiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada properti',
                      style: GoogleFonts.poppins(),
                    ),
                  );
                }

                final properties = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: properties.length,
                  itemBuilder: (context, index) {
                    final item = properties[index];
                    return _buildPropertyCard(item);
                  },
                );
              },
            ),
    );
  }

  Widget _buildPropertyCard(Property item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.mainImageUrl ?? 'https://via.placeholder.com/100',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            title: Text(
              item.namaProperty,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.formattedPrice,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1A237E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item.alamat,
                  style: GoogleFonts.poppins(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    _editProperty(item);
                  },
                  icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                  label: const Text(
                    'Edit',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _deleteProperty(item.idProperty),
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  label: const Text(
                    'Hapus',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
