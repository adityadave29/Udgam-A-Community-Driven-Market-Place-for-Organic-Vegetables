import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/controllers/auth_controller.dart';
import 'package:udgaam/services/supabase_service.dart';
import 'package:udgaam/routes/route_names.dart';

class RejectionReasonScreen extends StatelessWidget {
  RejectionReasonScreen({super.key});

  final AuthController controller = Get.find<AuthController>();

  Future<String> _fetchRejectionReason(String userId) async {
    print('Fetching rejection reason for userId: $userId');
    try {
      if (userId.isEmpty) {
        throw 'No user ID provided.';
      }
      final response = await SupabaseService.client
          .from('rejectionreason')
          .select('reason')
          .eq('farmer_id', userId)
          .maybeSingle();
      return response == null
          ? 'No rejection reason found for this farmer.'
          : response['reason'] ?? 'No specific reason provided.';
    } catch (e) {
      return 'Error fetching rejection reason: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userId = Get.arguments?['userId'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reason for Rejection',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.grey.shade800,
        elevation: 2,
        actions: [
          TextButton(
            onPressed: controller.logout,
            child: const Text(
              "Logout",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        color: Colors.black87, // Blackish grey background without gradient
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<String>(
          future: _fetchRejectionReason(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white, fontSize: 18));
            } else if (snapshot.hasData) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snapshot.data!,
                      style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Get.toNamed(Routenames.updateDetails,
                            arguments: {'farmerId': userId});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Update Details',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Text('No data available.',
                  style: TextStyle(fontSize: 18, color: Colors.grey));
            }
          },
        ),
      ),
    );
  }
}
