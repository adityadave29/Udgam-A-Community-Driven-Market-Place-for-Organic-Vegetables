import 'package:get/route_manager.dart';
import 'package:udgaam/mp_client_side/mp_c_homepage.dart';
import 'package:udgaam/mp_client_side/views/mp_c_address.dart';
import 'package:udgaam/mp_farmer_side/mp_f_homepage.dart';
import 'package:udgaam/mp_farmer_side/views/mp_f_listed_products.dart';
import 'package:udgaam/routes/route_names.dart';
import 'package:udgaam/views/Admin/admin_homepage.dart';
import 'package:udgaam/views/auth/login.dart';
import 'package:udgaam/views/auth/register.dart';
import 'package:udgaam/views/farmers-registration/farmer_home_page.dart';
import 'package:udgaam/views/farmers-registration/farmer_signup.dart';
import 'package:udgaam/views/farmers-registration/rejection_status.dart';
import 'package:udgaam/views/farmers-registration/update_details.dart';
import 'package:udgaam/views/home.dart';
import 'package:udgaam/views/profile/edit_profile.dart';
import 'package:udgaam/views/profile/show_user.dart';
import 'package:udgaam/views/replies/add_reply.dart';
import 'package:udgaam/views/settings/setting.dart';
import 'package:udgaam/views/posts/show_image.dart';
import 'package:udgaam/views/posts/show_post.dart';

class Routes {
  static final pages = [
    GetPage(name: Routenames.home, page: () => Home()),
    GetPage(name: Routenames.login, page: () => const Login()),
    GetPage(name: Routenames.register, page: () => const Register()),
    GetPage(name: Routenames.editProfile, page: () => const EditProile()),
    GetPage(
      name: Routenames.setting,
      page: () => Setting(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routenames.addReply,
      page: () => AddReply(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routenames.showPost,
      page: () => const ShowPost(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: Routenames.showImage,
      page: () => ShowImage(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: Routenames.showUser,
      page: () => ShowUser(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: Routenames.ecomHome,
      page: () => MpCHomePage(),
      transition: Transition.leftToRight,
    ),
    GetPage(name: Routenames.mpfhomepage, page: () => const MpFHomePage()),
    GetPage(name: Routenames.adminhomepage, page: () => const AdminHome()),
    GetPage(
        name: Routenames.farmerreghome, page: () => const FarmerRegHomePage()),
    GetPage(name: Routenames.farmerSignUp, page: () => const FarmerSignUp()),
    GetPage(
        name: Routenames.listedproducts, page: () => const MpFListedProducts()),
    GetPage(name: Routenames.mpchomepage, page: () => const MpCHomePage()),
    GetPage(
        name: Routenames.deliveryDetails,
        page: () => const DeliveryDetailsScreen()),
    GetPage(
      name: Routenames.rejectionReason,
      page: () => RejectionReasonScreen(),
    ), //
    GetPage(name: Routenames.updateDetails, page: () => UpdateDetailsScreen()),
  ];
}
