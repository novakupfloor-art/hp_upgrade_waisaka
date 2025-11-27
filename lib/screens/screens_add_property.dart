import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models_user.dart';
import '../../providers/api_routes/property_routes.dart';
import '../../utils/error_helper.dart';

class AddPropertyScreen extends StatefulWidget {
  final User user;

  const AddPropertyScreen({super.key, required this.user});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final List<XFile> _images = [];
  bool _isLoading = false;

  // Controllers
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _ltController = TextEditingController();
  final _lbController = TextEditingController();
  final _ktController = TextEditingController();
  final _kmController = TextEditingController();
  final _lantaiController = TextEditingController();
  final _deskripsiController = TextEditingController();

  String _selectedTipe = 'Dijual';
  String _selectedSertifikat = 'SHM';

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles);
      });
    }
  }

  Future<void> _submitProperty() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon pilih minimal 1 gambar')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Convert UI tipe to backend format
      String backendTipe = _selectedTipe == 'Dijual' ? 'jual' : 'sewa';

      final Map<String, String> fields = {
        'id_user': widget.user.idUser.toString(),
        'nama_property': _namaController.text,
        'harga': _hargaController.text,
        'alamat': _alamatController.text,
        'lt': _ltController.text,
        'lb': _lbController.text,
        'kamar_tidur': _ktController.text,
        'kamar_mandi': _kmController.text,
        'lantai': _lantaiController.text,
        'tipe': backendTipe,
        'surat': _selectedSertifikat,
        'isi': _deskripsiController.text,
        'id_kategori_property': '1', // Default to first category
        // Default location for now
        'id_provinsi': '34', // DIY
        'id_kabupaten': '3404', // Sleman
        'id_kecamatan': '340407', // Depok
      };

      List<String> imagePaths = _images.map((e) => e.path).toList();

      await PropertyRoutes.addProperty(fields, imagePaths);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Properti berhasil ditambahkan')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorHelper.getFriendlyMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tambah Properti',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Informasi Dasar'),
              _buildTextField('Nama Properti', _namaController),
              _buildTextField(
                'Harga (Rp)',
                _hargaController,
                keyboardType: TextInputType.number,
              ),
              _buildDropdown('Tipe', ['Dijual', 'Disewa'], _selectedTipe, (
                val,
              ) {
                setState(() => _selectedTipe = val!);
              }),
              const SizedBox(height: 20),

              _buildSectionTitle('Lokasi & Spesifikasi'),
              _buildTextField('Alamat Lengkap', _alamatController, maxLines: 2),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Luas Tanah (m²)',
                      _ltController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'Luas Bangunan (m²)',
                      _lbController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Kamar Tidur',
                      _ktController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'Kamar Mandi',
                      _kmController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Jumlah Lantai',
                      _lantaiController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      'Sertifikat',
                      ['SHM', 'HGB', 'Hak Pakai'],
                      _selectedSertifikat,
                      (val) {
                        setState(() => _selectedSertifikat = val!);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildSectionTitle('Deskripsi & Gambar'),
              _buildTextField(
                'Deskripsi Properti',
                _deskripsiController,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.image),
                label: const Text('Pilih Gambar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                ),
              ),
              if (_images.isNotEmpty)
                Container(
                  height: 100,
                  margin: const EdgeInsets.only(top: 12),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: Image.file(
                              File(_images[index].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _images.removeAt(index);
                                });
                              },
                              child: Container(
                                color: Colors.red,
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitProperty,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Simpan Properti',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1A237E),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Wajib diisi';
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String value,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        // ignore: deprecated_member_use
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
