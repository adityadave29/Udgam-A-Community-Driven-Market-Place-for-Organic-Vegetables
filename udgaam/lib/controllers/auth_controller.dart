// import 'package:get/get.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:udgaam/models/user_model.dart'; // Adjust path
// import 'package:udgaam/services/storage_service.dart';
// import 'package:udgaam/services/supabase_service.dart';
// import 'package:udgaam/utils/helper.dart';
// import 'package:udgaam/utils/storage_keys.dart';
// import 'package:udgaam/routes/route_names.dart';

// class AuthController extends GetxController {
//   var registerLoading = false.obs;
//   var loginLoading = false.obs;
//   final SupabaseClient supabaseClient = SupabaseService.client;

//   Future<void> register(String name, String email, String password) async {
//     try {
//       registerLoading.value = true;

//       final metadata = Metadata(
//         name: name,
//         email: email,
//         role: "User",
//         addresses: [],
//         defaultAddress: "",
//         phoneNumbers: [],
//         defaultPhoneNumber: "",
//       );

//       final AuthResponse data = await supabaseClient.auth.signUp(
//         email: email,
//         password: password,
//         data: metadata.toJson(),
//       );

//       if (data.user != null && data.session != null) {
//         StorageService.session.write(StorageKeys.userSession, {
//           'user': data.user!.toJson(),
//           'session': data.session!.toJson(),
//           'role': 'User',
//         });

//         await supabaseClient.from('users').upsert({
//           'id': data.user!.id,
//           'email': email,
//           'created_at': DateTime.now().toIso8601String(),
//           'metadata': metadata.toJson(),
//         });

//         registerLoading.value = false;
//         Get.offAllNamed(Routenames.home);
//       } else {
//         throw 'Registration failed: No user or session returned';
//       }
//     } on AuthException catch (error) {
//       registerLoading.value = false;
//       showSnackBar("Error", error.message);
//     } catch (error) {
//       registerLoading.value = false;
//       showSnackBar("Error", "Registration failed: $error");
//     }
//   }

//   Future<void> login(String email, String password, String selectedRole) async {
//     try {
//       loginLoading.value = true;

//       final response = await supabaseClient.auth.signInWithPassword(
//         email: email,
//         password: password,
//       );

//       final userId = response.user?.id;
//       if (userId == null || response.session == null) {
//         Get.snackbar('Error', 'Login failed: No user or session returned');
//         loginLoading.value = false;
//         return;
//       }

//       final userData = await supabaseClient
//           .from('users')
//           .select('metadata')
//           .eq('id', userId)
//           .single();

//       final actualRole = userData['metadata']?['role'] ?? "User";
//       print('Actual Role: $actualRole, Selected Role: $selectedRole');

//       if (selectedRole != actualRole) {
//         Get.snackbar(
//           'Error',
//           'Selected role ($selectedRole) does not match your account role ($actualRole)',
//         );
//         await supabaseClient.auth.signOut();
//         loginLoading.value = false;
//         return;
//       }

//       if (actualRole == "Farmer") {
//         final farmerData = await supabaseClient
//             .from('farmerreg')
//             .select('status')
//             .eq('id', userId)
//             .maybeSingle();

//         final farmerStatus = farmerData?['status'] as String? ?? "Pending";
//         print('Farmer Status: $farmerStatus');

//         switch (farmerStatus.toLowerCase()) {
//           case "approved":
//             StorageService.session.write(StorageKeys.userSession, {
//               'user': response.user!.toJson(),
//               'session': response.session!.toJson(),
//               'role': actualRole,
//             });
//             print('Navigating to mpfhomepage');
//             Get.offAllNamed(Routenames.mpfhomepage);
//             break;
//           case "rejected":
//             print('User ID before sign-out: $userId'); // Debug user ID
//             await supabaseClient.auth.signOut();
//             print('Navigating to rejection reason with userId: $userId');
//             Get.offAllNamed(
//               Routenames.rejectionReason,
//               arguments: {'userId': userId}, // Pass userId as argument
//             );
//             break;
//           case "pending":
//           default:
//             await supabaseClient.auth.signOut();
//             print('Showing pending snackbar');
//             Get.snackbar(
//               'Error',
//               'Only approved farmers can log in. Your status: $farmerStatus',
//             );
//             break;
//         }
//       } else {
//         StorageService.session.write(StorageKeys.userSession, {
//           'user': response.user!.toJson(),
//           'session': response.session!.toJson(),
//           'role': actualRole,
//         });

//         switch (actualRole) {
//           case "Admin":
//             print('Navigating to adminhomepage');
//             Get.offAllNamed(Routenames.adminhomepage);
//             break;
//           default:
//             print('Navigating to home');
//             Get.offAllNamed(Routenames.home);
//         }
//       }
//     } catch (e) {
//       print('Login Error: $e');
//       Get.snackbar('Error', 'Login failed: $e');
//     } finally {
//       loginLoading.value = false;
//     }
//   }

//   Future<void> logout() async {
//     try {
//       await supabaseClient.auth.signOut();
//       StorageService.session.remove(StorageKeys.userSession);
//       Get.offAllNamed(Routenames.login);
//     } catch (e) {
//       Get.snackbar('Error', 'Logout failed: $e');
//     }
//   }
// }

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udgaam/models/user_model.dart'; // Adjust path
import 'package:udgaam/services/storage_service.dart';
import 'package:udgaam/services/supabase_service.dart';
import 'package:udgaam/utils/helper.dart';
import 'package:udgaam/utils/storage_keys.dart';
import 'package:udgaam/routes/route_names.dart';

class AuthController extends GetxController {
  var registerLoading = false.obs;
  var loginLoading = false.obs;
  final SupabaseClient supabaseClient = SupabaseService.client;

  Future<void> register(String name, String email, String password) async {
    try {
      registerLoading.value = true;

      final metadata = Metadata(
        name: name,
        email: email,
        role: "User",
        addresses: [],
        defaultAddress: "",
        phoneNumbers: [],
        defaultPhoneNumber: "",
      );

      final AuthResponse data = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: metadata.toJson(),
      );

      if (data.user != null && data.session != null) {
        StorageService.session.write(StorageKeys.userSession, {
          'user': data.user!.toJson(),
          'session': data.session!.toJson(),
          'role': 'User',
        });

        await supabaseClient.from('users').upsert({
          'id': data.user!.id,
          'email': email,
          'created_at': DateTime.now().toIso8601String(),
          'metadata': metadata.toJson(),
        });

        registerLoading.value = false;
        Get.offAllNamed(Routenames.home);
      } else {
        throw 'Registration failed: No user or session returned';
      }
    } on AuthException catch (error) {
      registerLoading.value = false;
      showSnackBar("Error", error.message);
    } catch (error) {
      registerLoading.value = false;
      showSnackBar("Error", "Registration failed: $error");
    }
  }

  Future<void> login(String email, String password, String selectedRole) async {
    try {
      loginLoading.value = true;

      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final userId = response.user?.id;
      if (userId == null || response.session == null) {
        Get.snackbar('Error', 'Login failed: No user or session returned');
        loginLoading.value = false;
        return;
      }

      final userData = await supabaseClient
          .from('users')
          .select('metadata')
          .eq('id', userId)
          .single();

      final actualRole = userData['metadata']?['role'] ?? "User";
      print('Actual Role: $actualRole, Selected Role: $selectedRole');

      if (selectedRole != actualRole) {
        Get.snackbar(
          'Error',
          'Selected role ($selectedRole) does not match your account role ($actualRole)',
        );
        await supabaseClient.auth.signOut();
        loginLoading.value = false;
        return;
      }

      if (actualRole == "Farmer") {
        final farmerData = await supabaseClient
            .from('farmerreg')
            .select('status')
            .eq('id', userId)
            .maybeSingle();

        final farmerStatus = farmerData?['status'] as String? ?? "Pending";

        switch (farmerStatus.toLowerCase()) {
          case "approved":
            StorageService.session.write(StorageKeys.userSession, {
              'user': response.user!.toJson(),
              'session': response.session!.toJson(),
              'role': actualRole,
            });
            print('Navigating to mpfhomepage');
            Get.offAllNamed(Routenames.mpfhomepage);
            break;
          case "rejected":
            print('Navigating to rejection reason with userId: $userId');
            Get.offAllNamed(
              Routenames.rejectionReason,
              arguments: {'userId': userId},
            );
            break; // Removed signOut()
          case "pending":
          default:
            await supabaseClient.auth.signOut();
            print('Showing pending snackbar');
            Get.snackbar(
              'Error',
              'Only approved farmers can log in. Your status: $farmerStatus',
            );
            break;
        }
      } else {
        StorageService.session.write(StorageKeys.userSession, {
          'user': response.user!.toJson(),
          'session': response.session!.toJson(),
          'role': actualRole,
        });

        switch (actualRole) {
          case "Admin":
            print('Navigating to adminhomepage');
            Get.offAllNamed(Routenames.adminhomepage);
            break;
          default:
            print('Navigating to home');
            Get.offAllNamed(Routenames.home);
        }
      }
    } catch (e) {
      print('Login Error: $e');
      Get.snackbar('Error', 'Login failed: $e');
    } finally {
      loginLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await supabaseClient.auth.signOut();
      StorageService.session.remove(StorageKeys.userSession);
      Get.offAllNamed(Routenames.login);
    } catch (e) {
      Get.snackbar('Error', 'Logout failed: $e');
    }
  }
}
