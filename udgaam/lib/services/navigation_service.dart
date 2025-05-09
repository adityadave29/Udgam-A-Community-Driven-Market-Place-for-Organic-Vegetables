import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/mp_client_side/mp_c_homepage.dart';
import 'package:udgaam/views/home/home_page.dart';
import 'package:udgaam/views/news/news.dart';
import 'package:udgaam/views/profile/profile.dart';
import 'package:udgaam/views/posts/add_post.dart';

class NavigationService extends GetxService {
  var currentIndex = 0.obs;
  var previousIndex = 0.obs;

  // all pages
  List<Widget> pages() {
    return [
      MpCHomePage(),
      HomePage(),
      NewsFetcher(),
      AddPost(),
      const Profile()
    ];
  }

  void updateIndex(int index) {
    previousIndex.value = currentIndex.value;
    currentIndex.value = index;
  }

  void backtoPrevPage() {
    currentIndex.value = previousIndex.value;
  }
}
