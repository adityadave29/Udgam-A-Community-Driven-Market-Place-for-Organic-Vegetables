import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import 'package:udgaam/mp_client_side/views/mp_c_address.dart';
import 'package:udgaam/mp_client_side/views/mp_c_carousel.dart';
import 'package:udgaam/mp_client_side/views/mp_c_categorywidget.dart';
import 'package:udgaam/mp_client_side/views/mp_c_farmwise.dart';
import 'package:udgaam/mp_client_side/views/mp_c_searchbar.dart';

class MpCHomePage extends StatefulWidget {
  const MpCHomePage({super.key});

  @override
  State<MpCHomePage> createState() => _MpCHomePageState();
}

class _MpCHomePageState extends State<MpCHomePage> {
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
          Text("Address"),
          IconButton(
            onPressed: () {
              Get.to(() =>
                  const DeliveryDetailsScreen()); 
            },
            icon: Icon(Icons.location_on_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SearchBarWidget(),
            SizedBox(height: 8),
            CarouselWidget(),
            SizedBox(height: 20),
            CategoryWidget(),
            SizedBox(height: 20),
            FarmListScreen(),
          ],
        ),
      ),
    );
  }
}
