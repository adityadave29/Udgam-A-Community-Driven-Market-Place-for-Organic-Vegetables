import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/controllers/home_controller.dart';
import 'package:udgaam/views/notification/notification_page.dart';
import 'package:udgaam/views/search/search.dart';
import 'package:udgaam/widgets/loading.dart';
import 'package:udgaam/widgets/post_card.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final HomeController controller = Get.put(HomeController());

  final Map<String, String> categories = {
    'सभी': 'General', // To show all posts
    'फसल प्रबंधन': 'Crop Management',
    'मौसम और जलवायु': 'Weather & Climate',
    'कृषि उपकरण और तकनीक': 'Farming Equipment & Technology',
    'बाजार और मूल्य': 'Market & Pricing',
    'पशुपालन': 'Animal Husbandry',
    'अन्य': 'Other'
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: RefreshIndicator(
          onRefresh: () => controller.fetchPosts(),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Color(0x24242424),
                title: Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Row(
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
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Search(),
                              ),
                            ),
                            child: Icon(Icons.search, color: Colors.white),
                          ),
                          SizedBox(width: 15),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificationPage(),
                              ),
                            ),
                            child: Icon(Icons.notification_add_rounded,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                centerTitle: false,
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Obx(
                      () => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: categories.keys.map((hindiCategory) {
                            bool isSelected =
                                controller.selectedCategory.value ==
                                    categories[hindiCategory];
                            return GestureDetector(
                              onTap: () =>
                                  controller.selectCategory(hindiCategory),
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 15),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.green.shade700
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  hindiCategory,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Obx(
                      () => controller.loading.value
                          ? const Loading()
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const BouncingScrollPhysics(),
                              itemCount: controller.filteredPosts.length,
                              itemBuilder: (context, index) => PostCard(
                                  post: controller.filteredPosts[index]),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
