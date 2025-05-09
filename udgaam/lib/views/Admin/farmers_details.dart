import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/models/farmer_request_model.dart';
import 'package:udgaam/routes/route_names.dart';
import 'package:udgaam/views/Admin/farmer_service.dart';
import 'package:udgaam/views/Admin/widget/card.dart';

class FarmersDetails extends StatefulWidget {
  const FarmersDetails({super.key});

  @override
  State<FarmersDetails> createState() => _FarmersDetailsState();
}

class _FarmersDetailsState extends State<FarmersDetails> {
  List<FarmerRegistration> farmerList = [];
  List<FarmerRegistration> filteredList = [];
  bool isLoading = true;
  String selectedStatus = 'All';
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchFarmers();
  }

  Future<void> fetchFarmers() async {
    setState(() {
      isLoading = true;
      errorMessage = null; // Reset error message
    });
    try {
      final farmers = await FarmerService().getAllFarmers();
      debugPrint('Fetched ${farmers.length} farmers'); // Log fetched count
      setState(() {
        farmerList = farmers;
        filterFarmers();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error in fetchFarmers: $e');
      setState(() {
        farmerList = [];
        filteredList = [];
        isLoading = false;
        errorMessage = 'Failed to load farmers: $e';
      });
    }
  }

  void filterFarmers() {
    setState(() {
      filteredList = selectedStatus == 'All'
          ? farmerList
          : farmerList
              .where((farmer) => farmer.status == selectedStatus)
              .toList();
      debugPrint(
          'Filtered ${filteredList.length} farmers for status: $selectedStatus');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmers Detail'),
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed(Routenames.setting);
            },
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: DropdownButton<String>(
                  value: selectedStatus,
                  underline: Container(),
                  dropdownColor: Colors.grey[900],
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  items:
                      ['All', 'Pending', 'Approved', 'Rejected'].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        status,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                      filterFarmers();
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetchFarmers,
                    child: errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  errorMessage!,
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: fetchFarmers,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : filteredList.isEmpty
                            ? const Center(
                                child: Text(
                                  'No farmer data available.',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(8.0),
                                itemCount: filteredList.length,
                                itemBuilder: (context, index) {
                                  final farmer = filteredList[index];
                                  debugPrint(
                                      'Displaying farmer: ${farmer.userName ?? "Unknown"}, Status: ${farmer.status}');
                                  return FarmerInfoCard(farmer: farmer);
                                },
                              ),
                  ),
          ),
        ],
      ),
    );
  }
}
