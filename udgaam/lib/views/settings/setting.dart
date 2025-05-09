import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udgaam/controllers/setting_controller.dart';
import 'package:udgaam/services/supabase_service.dart';
import 'package:udgaam/utils/helper.dart';
import 'package:udgaam/views/settings/history_screen.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final SettingController controller = Get.put(SettingController());
  bool isLoading = true;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await SupabaseService.client
            .from('users')
            .select('metadata->>role')
            .eq('id', user.id)
            .single();
        setState(() {
          userRole = response['role'] as String? ?? 'Unknown';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          userRole = null; // No user logged in
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch user role: $e');
      setState(() {
        isLoading = false;
        userRole = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      confirmDialogue(
                        "Are you sure?",
                        "This action will log you out of the app.",
                        controller.logout,
                      );
                    },
                    leading: const Icon(Icons.logout),
                    title: const Text("Logout"),
                    trailing: const Icon(Icons.arrow_forward),
                  ),
                  if (userRole == 'User') // Only show if role is "User"
                    ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HistoryScreen()),
                        );
                      },
                      leading: const Icon(Icons.history_rounded),
                      title: const Text("Order history"),
                      trailing: const Icon(Icons.arrow_forward),
                    ),
                ],
              ),
            ),
    );
  }
}
