import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/services/navigation_service.dart';

class Home extends StatelessWidget {
  Home({super.key});
  final NavigationService navigationService = Get.put(NavigationService());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationService.currentIndex.value,
          onDestinationSelected: (value) =>
              navigationService.updateIndex(value),
          animationDuration: const Duration(microseconds: 500),
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              label: "Ecommerse",
              selectedIcon: Icon(Icons.shopping_bag),
            ),
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: "Home",
              selectedIcon: Icon(Icons.home),
            ),
            NavigationDestination(
              icon: Icon(Icons.newspaper_outlined),
              label: "News",
              selectedIcon: Icon(Icons.newspaper),
            ),
            NavigationDestination(
              icon: Icon(Icons.add_outlined),
              label: "Add",
              selectedIcon: Icon(Icons.add),
            ),
            NavigationDestination(
              icon: Icon(Icons.person_2_outlined),
              label: "Profile",
              selectedIcon: Icon(Icons.person_2),
            ),
          ],
        ),
        body: AnimatedSwitcher(
          duration: const Duration(microseconds: 500),
          switchInCurve: Curves.ease,
          switchOutCurve: Curves.easeInOut,
          child:
              navigationService.pages()[navigationService.currentIndex.value],
        ),
      ),
    );
  }
}
