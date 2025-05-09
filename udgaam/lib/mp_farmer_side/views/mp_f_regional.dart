import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegionalInsightsPage extends StatefulWidget {
  const RegionalInsightsPage({super.key});

  @override
  _RegionalInsightsPageState createState() => _RegionalInsightsPageState();
}

class _RegionalInsightsPageState extends State<RegionalInsightsPage> {
  final supabase = Supabase.instance.client;
  List<_LocationSalesData> locationSalesData = [];
  List<String> locations = [];
  String? selectedLocation;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchLocationSalesData();
  }

  Future<void> fetchLocationSalesData() async {
    try {
      // Fetch sales data
      final response = await supabase
          .from('synthetic_data')
          .select('product_name, farm_location, units_sold_kg');

      // Process data
      final List<dynamic> rawData = response as List<dynamic>;
      final Map<String, List<_ProductSales>> locationProductSales = {};

      for (var item in rawData) {
        final productName = item['product_name'] as String;
        final location = item['farm_location'] as String;
        final unitsSold = (item['units_sold_kg'] as num).toDouble();

        locationProductSales.putIfAbsent(location, () => []);
        locationProductSales[location]!
            .add(_ProductSales(productName, unitsSold));
      }

      // Aggregate and sort
      final List<_LocationSalesData> processedData = [];
      for (var location in locationProductSales.keys) {
        final products = locationProductSales[location]!;
        // Sum units sold per product
        final Map<String, double> productTotals = {};
        for (var sale in products) {
          productTotals.update(
            sale.productName,
            (value) => value + sale.unitsSold,
            ifAbsent: () => sale.unitsSold,
          );
        }
        // Sort products by units sold (descending)
        final sortedProducts = productTotals.entries
            .map((e) => _ProductSales(e.key, e.value))
            .toList()
          ..sort((a, b) => b.unitsSold.compareTo(a.unitsSold));
        processedData.add(_LocationSalesData(location, sortedProducts));
      }

      setState(() {
        locationSalesData = processedData;
        locations = processedData.map((e) => e.location).toList()..sort();
        if (locations.isNotEmpty) {
          selectedLocation = locations.first; // Default to first location
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location Dropdown
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select Region',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButton<String>(
                                value: selectedLocation,
                                hint: const Text('Choose a region'),
                                isExpanded: true,
                                items: locations.map((location) {
                                  return DropdownMenuItem<String>(
                                    value: location,
                                    child: Text(location),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedLocation = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Product List
                      if (selectedLocation != null)
                        Expanded(
                          child: Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Products in $selectedLocation (Most to Least Sold)',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: _buildProductList(selectedLocation!),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProductList(String location) {
    final locationData = locationSalesData.firstWhere(
      (data) => data.location == location,
      orElse: () => _LocationSalesData(location, []),
    );

    if (locationData.products.isEmpty) {
      return const Center(
          child: Text('No sales data available for this region.'));
    }

    return ListView.builder(
      itemCount: locationData.products.length,
      itemBuilder: (context, index) {
        final product = locationData.products[index];
        return ListTile(
          leading: Text('${index + 1}.'),
          title: Text(product.productName),
          trailing: Text('${product.unitsSold.toStringAsFixed(2)} kg'),
        );
      },
    );
  }
}

class _LocationSalesData {
  _LocationSalesData(this.location, this.products);

  final String location;
  final List<_ProductSales> products; // Sorted by units sold (descending)
}

class _ProductSales {
  _ProductSales(this.productName, this.unitsSold);

  final String productName;
  final double unitsSold;
}
