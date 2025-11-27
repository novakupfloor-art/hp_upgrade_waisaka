import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminTransaksiTab extends StatefulWidget {
  const AdminTransaksiTab({super.key});

  @override
  State<AdminTransaksiTab> createState() => _AdminTransaksiTabState();
}

class _AdminTransaksiTabState extends State<AdminTransaksiTab> {
  // Mock data
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'TRX-001',
      'user': 'John Doe',
      'package': 'Paket Premium',
      'amount': 'Rp 500.000',
      'status': 'Pending',
      'date': '2024-01-20',
    },
    {
      'id': 'TRX-002',
      'user': 'Jane Smith',
      'package': 'Paket Gold',
      'amount': 'Rp 1.000.000',
      'status': 'Confirmed',
      'date': '2024-01-19',
    },
    {
      'id': 'TRX-003',
      'user': 'Bob Johnson',
      'package': 'Paket Basic',
      'amount': 'Rp 100.000',
      'status': 'Rejected',
      'date': '2024-01-18',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transaksi Iklan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final trx = _transactions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        trx['id'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A237E),
                        ),
                      ),
                      _buildStatusChip(trx['status']),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildDetailRow('User', trx['user']),
                  _buildDetailRow('Paket', trx['package']),
                  _buildDetailRow('Harga', trx['amount']),
                  _buildDetailRow('Tanggal', trx['date']),
                  const SizedBox(height: 16),
                  if (trx['status'] == 'Pending')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              trx['status'] = 'Rejected';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Transaksi ditolak'),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Reject'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              trx['status'] = 'Confirmed';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Transaksi dikonfirmasi'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Confirmed':
        color = Colors.green;
        break;
      case 'Rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.grey[600])),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
