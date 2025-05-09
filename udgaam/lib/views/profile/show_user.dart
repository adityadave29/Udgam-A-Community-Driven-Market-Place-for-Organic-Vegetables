import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/controllers/profile_controller.dart';
import 'package:udgaam/routes/route_names.dart';
import 'package:udgaam/views/profile/profile.dart';
import 'package:udgaam/widgets/comment_card.dart';
import 'package:udgaam/widgets/image_circle.dart';
import 'package:udgaam/widgets/loading.dart';
import 'package:udgaam/widgets/post_card.dart';

class ShowUser extends StatefulWidget {
  const ShowUser({super.key});

  @override
  State<ShowUser> createState() => _ShowUserState();
}

class _ShowUserState extends State<ShowUser> {
  final String userId = Get.arguments;
  final ProfileController controller = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    controller.getUser(userId);
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
                expandedHeight: 110,
                collapsedHeight: 110,
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
                          Obx(
                            () => controller.userLoading.value
                                ? const Loading()
                                : Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          controller.user.value.metadata!.name!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                          ),
                                        ),
                                        SizedBox(
                                          width: context.width * 0.60,
                                          child: Text(
                                            controller.user.value.metadata!
                                                .description!,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          CircleImage(
                            radius: 40,
                            url: controller.user.value.metadata?.image,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
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
                          itemBuilder: (context, index) =>
                              PostCard(post: controller.posts[index]),
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
