import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminPaketTab extends StatefulWidget {
  const AdminPaketTab({super.key});

  @override
  State<AdminPaketTab> createState() => _AdminPaketTabState();
}

class _AdminPaketTabState extends State<AdminPaketTab> {
  // Mock data
  final List<Map<String, dynamic>> _packages = [
    {
      'id': 1,
      'name': 'Paket Basic',
      'price': 'Rp 100.000',
      'duration': '30 Hari',
      'quota': '5 Iklan',
    },
    {
      'id': 2,
      'name': 'Paket Premium',
      'price': 'Rp 500.000',
      'duration': '90 Hari',
      'quota': '20 Iklan',
    },
    {
      'id': 3,
      'name': 'Paket Gold',
      'price': 'Rp 1.000.000',
      'duration': '180 Hari',
      'quota': 'Unlimited',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kelola Paket Iklan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddPackageDialog();
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _packages.length,
        itemBuilder: (context, index) {
          final pkg = _packages[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                pkg['name'],
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color(0xFF1A237E),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.monetization_on, pkg['price']),
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.timer, pkg['duration']),
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.inventory, pkg['quota']),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  _showEditPackageDialog(pkg);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.poppins(color: Colors.grey[800])),
      ],
    );
  }

  void _showAddPackageDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();
    final quotaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Tambah Paket',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Paket'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Harga (Rp)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'Durasi (Hari)'),
              ),
              TextField(
                controller: quotaController,
                decoration: const InputDecoration(labelText: 'Kuota Iklan'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
                setState(() {
                  _packages.add({
                    'id': _packages.length + 1,
                    'name': nameController.text,
                    'price': 'Rp ${priceController.text}',
                    'duration': durationController.text,
                    'quota': quotaController.text,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Paket berhasil ditambahkan')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditPackageDialog(Map<String, dynamic> pkg) {
    final nameController = TextEditingController(text: pkg['name']);
    final priceController = TextEditingController(
      text: pkg['price'].toString().replaceAll('Rp ', '').replaceAll('.', ''),
    );
    final durationController = TextEditingController(text: pkg['duration']);
    final quotaController = TextEditingController(text: pkg['quota']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Paket',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Paket'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Harga (Rp)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'Durasi'),
              ),
              TextField(
                controller: quotaController,
                decoration: const InputDecoration(labelText: 'Kuota Iklan'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
                setState(() {
                  pkg['name'] = nameController.text;
                  pkg['price'] = 'Rp ${priceController.text}';
                  pkg['duration'] = durationController.text;
                  pkg['quota'] = quotaController.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Paket berhasil diperbarui')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
