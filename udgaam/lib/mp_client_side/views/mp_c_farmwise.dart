import 'package:flutter/material.dart';
import 'package:udgaam/mp_client_side/widgets/mp_c_farmproducts.dart';
import 'package:udgaam/services/supabase_service.dart';
import 'package:udgaam/utils/env.dart';

class FarmListScreen extends StatefulWidget {
  const FarmListScreen({super.key});

  @override
  State<FarmListScreen> createState() => _FarmListScreenState();
}

class _FarmListScreenState extends State<FarmListScreen> {
  bool isLoadingFarmers = true;
  List<Map<String, dynamic>> farmers = [];
  bool isSortAZ = true; // True for A-Z, False for Z-A

  // Define the getS3Url function
  String getS3Url(String path) {
    return "${Env.supabaseUrl}/storage/v1/object/public/$path";
  }

  @override
  void initState() {
    super.initState();
    _fetchFarmers();
  }

  Future<void> _fetchFarmers() async {
    setState(() => isLoadingFarmers = true);
    try {
      // Fetch farmers from users table
      final userResponse = await SupabaseService.client
          .from('users')
          .select('id, metadata')
          .eq('metadata->>role', 'Farmer');

      final farmerIds =
          userResponse.map((farmer) => farmer['id'] as String).toList();

      // Fetch farm details from farmerreg table
      final farmResponse = await SupabaseService.client
          .from('farmerreg')
          .select('id, address, farmImage')
          .inFilter('id', farmerIds);

      // Fetch product counts for each farmer
      final productResponse = await SupabaseService.client
          .from('products')
          .select('id')
          .inFilter('id', farmerIds);

      // Create a set of farmer IDs with at least one product
      final farmerIdsWithProducts =
          productResponse.map((product) => product['id'] as String).toSet();

      // Merge user and farm data, filtering farmers with products
      final farmerData = userResponse
          .map((user) {
            if (!farmerIdsWithProducts.contains(user['id'])) {
              return null; // Skip farmers with no products
            }
            final farm = farmResponse.firstWhere(
              (f) => f['id'] == user['id'],
              orElse: () => {'address': 'Unknown', 'farmImage': null},
            );
            return {
              'id': user['id'],
              'name': user['metadata']?['name'] as String? ?? 'Unknown Farmer',
              'location': farm['address'] as String,
              'farmImage': farm['farmImage'] as String?,
            };
          })
          .where((farmer) => farmer != null)
          .cast<Map<String, dynamic>>()
          .toList();

      setState(() {
        farmers = farmerData;
        _sortFarmers(); // Sort initially
        isLoadingFarmers = false;
      });
    } catch (e) {
      debugPrint('Failed to fetch farmers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load farmers: $e')),
      );
      setState(() => isLoadingFarmers = false);
    }
  }

  void _sortFarmers() {
    setState(() {
      farmers.sort((a, b) {
        final nameA =
            (a['name'] as String).toLowerCase(); // Lowercase for sorting
        final nameB =
            (b['name'] as String).toLowerCase(); // Lowercase for sorting
        return isSortAZ ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
      });
    });
  }

  void _toggleSortOrder() {
    setState(() {
      isSortAZ = !isSortAZ;
      _sortFarmers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Our Farms',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: Icon(
                  isSortAZ
                      ? Icons.sort_by_alpha
                      : Icons.text_rotate_vertical, // Z-A icon
                  color: Colors.green[700],
                ),
                onPressed: _toggleSortOrder,
                tooltip: isSortAZ ? 'Sort Z-A' : 'Sort A-Z',
              ),
            ],
          ),
          const SizedBox(height: 12),
          isLoadingFarmers
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.green))
              : farmers.isEmpty
                  ? const Text(
                      'No farmers with products found.',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: farmers.length,
                      itemBuilder: (context, index) {
                        final farmer = farmers[index];
                        return _buildFarmerTile(
                          farmer['id'],
                          farmer['name'],
                          farmer['location'],
                          farmer['farmImage'],
                        );
                      },
                    ),
        ],
      ),
    );
  }

  Widget _buildFarmerTile(
      String id, String name, String location, String? farmImage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FarmWiseProduct(farmerId: id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.green[700]!, width: 0.5),
        ),
        child: Row(
          children: [
            farmImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      getS3Url(farmImage),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[900],
                        child: const Icon(Icons.image_not_supported,
                            color: Colors.white70),
                      ),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[900],
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.white70),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              "$name's Farm",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 7),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text("📍"),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white70),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
