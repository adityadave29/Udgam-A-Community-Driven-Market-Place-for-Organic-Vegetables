import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udgaam/models/farmer_request_model.dart';

class FarmerDetailsPage extends StatelessWidget {
  final FarmerRegistration farmer;

  const FarmerDetailsPage({super.key, required this.farmer});

  String getBucketImageUrl(String url) {
    return 'https://wzcqzylxgphylogyzkzf.supabase.co/storage/v1/object/public/$url';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Farmer Details'),
        backgroundColor: Colors.grey[900],
        elevation: 5.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey[700]!, width: 1.5),
              ),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2),
                },
                children: [
                  _buildTableRow('Name', farmer.userName ?? 'Unknown'),
                  _buildTableRow('Email', farmer.userEmail ?? 'Unknown'),
                  _buildTableRow('Phone', farmer.number),
                  _buildTableRow('Farmer ID', farmer.farmerId),
                  _buildTableRow('Address', farmer.address),
                  _buildTableRow('Farm Size', farmer.farmSize),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildImageGallery(
                'Farm Image', getBucketImageUrl(farmer.farmImage),
                icon: Icons.landscape),
            _buildImageGallery(
                'Certificate', getBucketImageUrl(farmer.certificate),
                icon: Icons.verified),
            const SizedBox(height: 20),
            // Approve & Reject Buttons (Only if status is 'Pending')
            farmer.status == 'Pending'
                ? Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          onPressed: () => approveFarmer(
                              context, farmer.farmerId, farmer.number),
                          child: const Text('Approve',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: () =>
                              _showRejectionDialog(context, farmer.id),
                          child: const Text('Reject',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'Status: ${farmer.status}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallery(String label, String? imageUrl,
      {required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.grey[900],
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              imageUrl!,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 100,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  void approveFarmer(
      BuildContext context, String farmerId, String? phoneNumber) async {
    print('Approved Farmer ID: $farmerId');
    try {
      await Supabase.instance.client
          .from('farmerreg')
          .update({'status': 'Approved'}).eq('farmerId', farmerId);
      Navigator.pop(context); // Navigate back after approval
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve farmer: $e')),
      );
    }
  }

  void _showRejectionDialog(BuildContext context, String farmerUuid) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Reject Farmer',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please provide a reason for rejection:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reasonController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter reason here...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Back button, close dialog
              },
              child: const Text('Back', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a reason')),
                  );
                  return;
                }
                await rejectFarmer(context, farmerUuid, reason);
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Navigate back to previous page
              },
              child:
                  const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> rejectFarmer(
      BuildContext context, String farmerUuid, String reason) async {
    print('Attempting to reject Farmer UUID: $farmerUuid with reason: $reason');

    // Step 1: Try to insert rejection reason into rejectionreason table
    try {
      await Supabase.instance.client.from('rejectionreason').insert({
        'farmer_id': farmerUuid, // Use farmer.id (UUID)
        'reason': reason,
      });
    } catch (e) {
      debugPrint(
          'Error: Unable to add rejection reason to rejectionreason table: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add rejection reason: $e')),
      );
      return; // Exit if insertion fails
    }

    // Step 2: If rejectionreason insertion succeeds, update farmerreg status
    try {
      await Supabase.instance.client
          .from('farmerreg')
          .update({'status': 'Rejected'}).eq('id', farmerUuid);
      print('Successfully rejected Farmer UUID: $farmerUuid');
    } catch (e) {
      print('Failed to update farmerreg status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update farmer status: $e')),
      );
    }
  }
}
