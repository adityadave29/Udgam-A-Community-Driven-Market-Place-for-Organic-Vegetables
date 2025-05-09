import 'package:get/get.dart';
import 'package:udgaam/routes/route_names.dart';
import 'package:udgaam/services/storage_service.dart';
import 'package:udgaam/services/supabase_service.dart';
import 'package:udgaam/utils/storage_keys.dart';

class SettingController extends GetxController {
  void logout() async {
    StorageService.session.remove(StorageKeys.userSession);
    await SupabaseService.client.auth.signOut();
    Get.offAllNamed(Routenames.login);
  }
}
