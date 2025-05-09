import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/mp_farmer_side/views/mp_f_add_product.dart';
import 'package:udgaam/mp_farmer_side/views/mp_f_dashboard.dart';
import 'package:udgaam/mp_farmer_side/views/mp_f_listed_products.dart';
import 'package:udgaam/mp_farmer_side/views/mp_f_orders.dart';
import 'package:udgaam/mp_farmer_side/views/mp_f_profile.dart';
import 'package:udgaam/routes/route_names.dart';

class MpFHomePage extends StatefulWidget {
  const MpFHomePage({super.key});

  @override
  State<MpFHomePage> createState() => _MpFHomePageState();
}

class _MpFHomePageState extends State<MpFHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    MpFDashboard(),
    MpFOrders(),
    MpFAddProducts(),
    MpFListedProducts(),
    MpFProfile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                "assets/logo.png",
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            Text(
              "Udgam",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed(Routenames.setting);
            },
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }
}
