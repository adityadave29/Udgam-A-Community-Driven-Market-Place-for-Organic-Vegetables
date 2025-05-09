import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/controllers/farmer_registration.dart';
import 'package:udgaam/models/farmer_request_model.dart';
import 'package:udgaam/services/supabase_service.dart';

class MpFProfile extends StatefulWidget {
  const MpFProfile({super.key});

  @override
  State<MpFProfile> createState() => _MpFProfileState();
}

class _MpFProfileState extends State<MpFProfile> {
  final FarmerRegiatrationController regcontroller =
      Get.put(FarmerRegiatrationController());
  final SupabaseService supabaseService = Get.find<SupabaseService>();

  FarmerRegistration? farmerData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFarmerDetails();
  }

  Future<void> fetchFarmerDetails() async {
    final userId = supabaseService.currentUser.value!.id;
    final response = await SupabaseService.client
        .from('farmerreg')
        .select()
        .eq('id', userId)
        .single();

    setState(() {
      farmerData = FarmerRegistration.fromJson(response);
      isLoading = false;
    });
  }

  String getBucketImageUrl(String url) {
    return 'https://wzcqzylxgphylogyzkzf.supabase.co/storage/v1/object/public/$url';
  }

  Widget _buildFieldCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2726), // Blackish-grey background
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white, width: 1), // White border
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF00C853), // Green titles
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white, // White details
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(String label, String? imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white, // White image title
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: Colors.white, width: 1), // White border
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl!,
                width: double.infinity,
                fit: BoxFit.contain, // Full image display
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200, // Fallback height for broken images
                  color: const Color(0xFF1E2726),
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.white30,
                    size: 60,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF212121), // Darker blackish-grey for whole screen
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00C853),
                strokeWidth: 3,
              ),
            )
          : farmerData != null
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2726), // Blackish-grey
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                              color: Colors.white, width: 1), // White border
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: AssetImage(
                                  'assets/farmer.png'), // Farmer profile picture
                              backgroundColor: Color(0xFF00C853),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  supabaseService.currentUser.value!
                                          .userMetadata?["name"] ??
                                      'N/A',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Farmer ID: ${farmerData!.farmerId}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Fields Section
                      _buildFieldCard(
                          'Email',
                          supabaseService
                                  .currentUser.value!.userMetadata?["email"] ??
                              'N/A'),
                      _buildFieldCard('Phone', farmerData!.number),
                      _buildFieldCard('Address', farmerData!.address),
                      _buildFieldCard('Farm Size', farmerData!.farmSize),
                      const SizedBox(height: 20),
                      // Images Section
                      _buildImageSection('Farm Image',
                          getBucketImageUrl(farmerData!.farmImage)),
                      _buildImageSection('Certificate',
                          getBucketImageUrl(farmerData!.certificate)),
                    ],
                  ),
                )
              : const Center(
                  child: Text(
                    'No data found for this user.',
                    style: TextStyle(
                      color: Color(0xFF00C853),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
    );
  }
}
