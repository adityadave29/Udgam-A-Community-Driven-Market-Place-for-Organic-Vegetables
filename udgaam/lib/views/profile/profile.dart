import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/controllers/profile_controller.dart';
import 'package:udgaam/routes/route_names.dart';
import 'package:udgaam/services/supabase_service.dart';
import 'package:udgaam/utils/styles/button_styles.dart';
import 'package:udgaam/widgets/comment_card.dart';
import 'package:udgaam/widgets/image_circle.dart';
import 'package:udgaam/widgets/loading.dart';
import 'package:udgaam/widgets/post_card.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ProfileController controller = Get.put(ProfileController());
  final SupabaseService supabaseService = Get.find<SupabaseService>();

  @override
  void initState() {
    if (supabaseService.currentUser.value?.id != null) {
      controller.fetchUserPosts(supabaseService.currentUser.value!.id);
      controller.fetchComments(supabaseService.currentUser.value!.id);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Icon(Icons.language),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed(Routenames.setting);
            },
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 160,
                collapsedHeight: 160,
                automaticallyImplyLeading: false,
                flexibleSpace: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                supabaseService
                                    .currentUser.value!.userMetadata?["name"],
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: context.width * 0.60,
                                child: Text(supabaseService.currentUser.value
                                        ?.userMetadata?["description"] ??
                                    "Hey, I am using Udgaam!"),
                              ),
                            ],
                          ),
                          CircleImage(
                            radius: 40,
                            url: supabaseService
                                .currentUser.value?.userMetadata?["image"],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  Get.toNamed(Routenames.editProfile),
                              style: customOutlineStyle(),
                              child: Text("Edit Profile"),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: customOutlineStyle(),
                              child: Text("Share Profile"),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                floating: true,
                pinned: true,
                delegate: SliverAppBarDelegate(
                  const TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(text: "Post"),
                      Tab(text: "Replies"),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              Obx(
                () => SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      if (controller.postLoading.value)
                        const Loading()
                      else if (controller.posts.isNotEmpty)
                        ListView.builder(
                          itemCount: controller.posts.length,
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) => PostCard(
                            post: controller.posts[index],
                            isAuthCard: true,
                            callback: controller.deletePost,
                          ),
                        )
                      else
                        const Center(
                          child: Text("No post found!"),
                        )
                    ],
                  ),
                ),
              ),
              Obx(
                () => SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      if (controller.replyLoading.value)
                        const Loading()
                      else if (controller.replies.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: controller.replies.length,
                          itemBuilder: (context, index) =>
                              CommentCard(reply: controller.replies[index]),
                        )
                      else
                        const Center(
                          child: Text("No replies found"),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  SliverAppBarDelegate(this._tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black,
      child: _tabBar,
    );
  }

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
