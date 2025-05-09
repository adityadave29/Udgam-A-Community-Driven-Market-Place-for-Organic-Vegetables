import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:udgaam/Theme/theme.dart';
import 'package:udgaam/mp_client_side/controllers/cart_controller.dart';
import 'package:udgaam/mp_farmer_side/controller/add_product_controller.dart';
import 'package:udgaam/routes/route.dart';
import 'package:udgaam/routes/route_names.dart';
import 'package:udgaam/services/storage_service.dart';
import 'package:udgaam/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await GetStorage.init();
  Get.put(AddProductController());
  Get.put(SupabaseService());
  Get.put(CartController());

  // SystemChrome.setEnabledSystemUIMode(
  //   SystemUiMode.manual,
  //   overlays: [SystemUiOverlay.top],
  // );

  String initialRoute = await determineInitialRoute();

  runApp(MyApp(initialRoute: initialRoute));
}

Future<String> determineInitialRoute() async {
  final userSession = StorageService.userSession;

  if (userSession != null) {
    final userId = userSession['user']['id'];

    try {
      final userData = await SupabaseService.client
          .from("users")
          .select("metadata")
          .eq("id", userId)
          .single();

      final userRole = userData['metadata']?['role'] ?? "User";

      switch (userRole) {
        case "Admin":
          return Routenames.adminhomepage;
        case "Farmer":
          return Routenames.mpfhomepage;
        default:
          return Routenames.home;
      }
    } catch (error) {
      return Routenames.login;
    }
  }

  return Routenames.login;
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Udgam',
      theme: theme,
      getPages: Routes.pages,
      initialRoute: initialRoute,
      defaultTransition: Transition.noTransition,
    );
  }
}
