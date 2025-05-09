import 'package:flutter/material.dart';
import 'package:udgaam/mp_farmer_side/views/mp_f_regional.dart';
import 'package:udgaam/mp_farmer_side/views/mp_f_time_series_page.dart';

class Insights extends StatefulWidget {
  const Insights({super.key});

  @override
  State<Insights> createState() => _InsightsState();
}

class _InsightsState extends State<Insights> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const TimeSeriesPage(),
    const RegionalInsightsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights Dashboard'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Time Series',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Regional Insights',
          ),
        ],
      ),
    );
  }
}
