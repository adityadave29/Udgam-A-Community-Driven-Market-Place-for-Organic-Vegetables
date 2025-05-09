import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/controllers/notification_controller.dart';
import 'package:udgaam/routes/route_names.dart';
import 'package:udgaam/services/supabase_service.dart';
import 'package:udgaam/utils/helper.dart';
import 'package:udgaam/widgets/image_circle.dart';
import 'package:udgaam/widgets/loading.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationController controller = Get.put(NotificationController());

  @override
  void initState() {
    controller
        .fetchNotifications(Get.find<SupabaseService>().currentUser.value!.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(), icon: const Icon(Icons.close)),
        title: Text('Notification'),
      ),
      body: SingleChildScrollView(
        child: Obx(
          () => controller.loading.value
              ? const Loading()
              : Column(
                  children: [
                    if (controller.notifications.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: controller.notifications.length,
                        itemBuilder: (context, index) => ListTile(
                          onTap: () => {
                            Get.toNamed(Routenames.showPost,
                                arguments:
                                    controller.notifications[index].postId),
                          },
                          leading: CircleImage(
                            url: controller
                                .notifications[index].user?.metadata?.image,
                          ),
                          title: Text(controller
                              .notifications[index].user!.metadata!.name!),
                          trailing: Text(
                            formateDateFromNow(
                                controller.notifications[index].createdAt!),
                          ),
                          subtitle: Text(
                              controller.notifications[index].notification!),
                        ),
                      )
                    else
                      const Text("No Notification Found"),
                  ],
                ),
        ),
      ),
    );
  }
}
