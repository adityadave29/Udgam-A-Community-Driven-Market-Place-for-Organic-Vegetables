import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class TimeSeriesPage extends StatefulWidget {
  const TimeSeriesPage({super.key});

  @override
  _TimeSeriesPageState createState() => _TimeSeriesPageState();
}

class _TimeSeriesPageState extends State<TimeSeriesPage> {
  final supabase = Supabase.instance.client;
  List<_SalesData> allSalesData = [];
  List<_MonthlyCategorySales> monthlyCategorySales = [];
  bool isLoading = true;
  String? errorMessage;

  // Date range variables
  DateTime? minDate;
  DateTime? maxDate;

  // Categories data
  List<String> allCategories = [];
  List<String> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    fetchSalesData();
  }

  Future<void> fetchSalesData() async {
    try {
      // Fetch all sales data ordered by sale_date
      final response = await supabase
          .from('synthetic_data')
          .select('product_name, category, sale_date, units_sold_kg')
          .order('sale_date', ascending: true);

      // Process data for charting
      final List<dynamic> rawData = response as List<dynamic>;
      final List<_SalesData> processedData = [];
      final Set<String> categories = {};

      // For determining date range
      DateTime? earliestDate;
      DateTime? latestDate;

      for (var item in rawData) {
        final productName = item['product_name'] as String;
        final category = item['category'] as String;
        final saleDate = DateTime.parse(item['sale_date'] as String);
        final unitsSold = (item['units_sold_kg'] as num).toDouble();

        // Track earliest and latest dates
        if (earliestDate == null || saleDate.isBefore(earliestDate)) {
          earliestDate = saleDate;
        }
        if (latestDate == null || saleDate.isAfter(latestDate)) {
          latestDate = saleDate;
        }

        categories.add(category);

        final salesData = _SalesData(saleDate, unitsSold)
          ..productName = productName
          ..category = category;

        processedData.add(salesData);
      }

      setState(() {
        allSalesData = processedData;
        allCategories = categories.toList()..sort();
        selectedCategories = [
          ...allCategories
        ]; // Initially select all categories

        // Set min and max dates for chart
        if (earliestDate != null && latestDate != null) {
          // Start from the first day of the earliest month
          minDate = DateTime(earliestDate.year, earliestDate.month, 1);
          // End at the last day of the latest month
          maxDate = DateTime(latestDate.year, latestDate.month + 1, 0);
        }

        generateMonthlyCategorySales();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }

  void generateMonthlyCategorySales() {
    if (minDate == null || maxDate == null) return;

    // Create a list of all months between minDate and maxDate
    final List<DateTime> allMonths = [];
    DateTime currentMonth = DateTime(minDate!.year, minDate!.month, 1);

    while (!currentMonth.isAfter(maxDate!)) {
      allMonths.add(currentMonth);
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    }

    // Initialize monthly sales data for all months
    List<_MonthlyCategorySales> result = [];
    for (var month in allMonths) {
      final monthSales = _MonthlyCategorySales(month);
      // Initialize all categories with zero
      for (var category in allCategories) {
        monthSales.categorySales[category] = 0;
      }
      result.add(monthSales);
    }

    // Populate with actual sales data
    for (var data in allSalesData) {
      // Find the corresponding month in our list
      final monthStart = DateTime(data.date.year, data.date.month, 1);
      final monthIndex = result.indexWhere((m) =>
          m.month.year == monthStart.year && m.month.month == monthStart.month);

      if (monthIndex >= 0) {
        // Add sales data to the appropriate category
        result[monthIndex].categorySales[data.category] =
            (result[monthIndex].categorySales[data.category] ?? 0) +
                data.unitsSold;
      }
    }

    monthlyCategorySales = result;
  }

  void filterDataByCategories() {
    // No need to filter raw data, we'll filter during chart creation
    setState(() {});
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
                    children: [
                      _buildCategoryFilter(),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SfCartesianChart(
                          primaryXAxis: DateTimeAxis(
                            title: AxisTitle(text: 'Month'),
                            dateFormat: DateFormat('MMM yyyy'),
                            intervalType: DateTimeIntervalType.months,
                            // Set the minimum and maximum dates
                            minimum: minDate,
                            maximum: maxDate,
                            // Ensure a reasonable interval for better readability
                            interval: 1,
                          ),
                          primaryYAxis: NumericAxis(
                            title:
                                AxisTitle(text: 'Cumulative Units Sold (kg)'),
                          ),
                          title: ChartTitle(text: 'Monthly Sales by Category'),
                          legend: Legend(isVisible: true),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: _buildChartSeries(),
                          // Enable zooming and panning for better navigation of many months
                          zoomPanBehavior: ZoomPanBehavior(
                            enablePanning: true,
                            enablePinching: true,
                            enableDoubleTapZooming: true,
                            enableSelectionZooming: true,
                            enableMouseWheelZooming: true,
                            zoomMode: ZoomMode.x,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCategoryFilter() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: allCategories.map((category) {
                final isSelected = selectedCategories.contains(category);
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedCategories.add(category);
                      } else {
                        selectedCategories.remove(category);
                      }
                      filterDataByCategories();
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedCategories = [...allCategories];
                      filterDataByCategories();
                    });
                  },
                  child: const Text('Select All'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedCategories = [];
                      filterDataByCategories();
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<LineSeries<_MonthlyCategorySales, DateTime>> _buildChartSeries() {
    // Create a series for each selected category
    return selectedCategories.map((category) {
      return LineSeries<_MonthlyCategorySales, DateTime>(
        dataSource: monthlyCategorySales,
        xValueMapper: (_MonthlyCategorySales sales, _) => sales.month,
        yValueMapper: (_MonthlyCategorySales sales, _) =>
            sales.categorySales[category],
        name: category,
        // Enable markers to make individual data points more visible
        markerSettings: const MarkerSettings(isVisible: true),
        dataLabelSettings: const DataLabelSettings(isVisible: false),
      );
    }).toList();
  }
}

// Class to store raw sales data
class _SalesData {
  _SalesData(this.date, this.unitsSold);

  final DateTime date;
  final double unitsSold;
  String get productName => _productName;
  String get category => _category;
  String _productName = '';
  String _category = '';

  // Setters for properties
  set productName(String value) => _productName = value;
  set category(String value) => _category = value;
}

// Class to store aggregated monthly sales by category
class _MonthlyCategorySales {
  _MonthlyCategorySales(this.month);

  final DateTime month;
  final Map<String, double> categorySales = {};
}
