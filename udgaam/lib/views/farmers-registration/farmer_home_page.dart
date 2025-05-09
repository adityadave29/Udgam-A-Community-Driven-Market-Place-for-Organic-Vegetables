import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udgaam/controllers/farmer_registration.dart';
import 'package:udgaam/routes/route_names.dart';
import 'package:udgaam/utils/env.dart';
import 'package:udgaam/utils/helper.dart';
import 'package:udgaam/widgets/auth_input.dart';
import 'package:udgaam/widgets/registration_image_preview.dart';
import 'package:udgaam/services/supabase_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class FarmerRegHomePage extends StatefulWidget {
  const FarmerRegHomePage({super.key});

  @override
  State<FarmerRegHomePage> createState() => _FarmerRegHomePageState();
}

class _FarmerRegHomePageState extends State<FarmerRegHomePage> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController farmsizeController = TextEditingController();
  final TextEditingController farmidController = TextEditingController();

  final FarmerRegiatrationController controller =
      Get.put(FarmerRegiatrationController());
  final FarmerRegiatrationController certificatecontroller =
      Get.put(FarmerRegiatrationController());

  bool _isFetchingLocation = false;

  // Function to get current location and convert to address
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Show dialog to prompt enabling location services
        await _showLocationServiceDialog();
        setState(() => _isFetchingLocation = false);
        return;
      }

      // Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          showSnackBar("Error", "Location permissions are denied.");
          setState(() => _isFetchingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        showSnackBar("Error",
            "Location permissions are permanently denied, please enable them in settings.");
        setState(() => _isFetchingLocation = false);
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Convert coordinates to address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = [
          place.street,
          place.locality,
          place.administrativeArea,
          place.postalCode,
          place.country
        ].where((element) => element != null && element.isNotEmpty).join(", ");

        addressController.text = address;
        showSnackBar("Success", "Location fetched successfully!");
      } else {
        showSnackBar("Error", "Could not fetch address.");
      }
    } catch (e) {
      showSnackBar("Error", "Failed to get location: $e");
    } finally {
      setState(() => _isFetchingLocation = false);
    }
  }

  // Dialog to prompt enabling location services
  Future<void> _showLocationServiceDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
              'Location services are disabled. Please enable them to fetch your farm address.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Enable'),
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
                if (await Geolocator.isLocationServiceEnabled()) {
                  _getCurrentLocation();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> submit() async {
    if (_form.currentState!.validate()) {
      try {
        final userId = SupabaseService.client.auth.currentUser?.id;
        if (userId == null) {
          showSnackBar("Error", "User not found");
          return;
        }

        String farmImagePath = "";
        String certificatePath = "";

        if (controller.farmImage.value != null &&
            controller.farmImage.value!.existsSync()) {
          farmImagePath = await SupabaseService.client.storage
              .from(Env.s3Bucket)
              .upload("$userId/farm.png", controller.farmImage.value!,
                  fileOptions: const FileOptions(upsert: true));
        }

        if (certificatecontroller.certificate.value != null &&
            certificatecontroller.certificate.value!.existsSync()) {
          certificatePath = await SupabaseService.client.storage
              .from(Env.s3Bucket)
              .upload("$userId/certificate.png",
                  certificatecontroller.certificate.value!,
                  fileOptions: const FileOptions(upsert: true));
        }

        await SupabaseService.client.from("farmerreg").insert({
          "id": userId,
          "number": phoneController.text,
          "address": addressController.text,
          "farmsize": farmsizeController.text,
          "farmerId": farmidController.text,
          "farmImage": farmImagePath,
          "certificate": certificatePath,
        });
        showSnackBar("Success", "Registration completed successfully");
        Get.offAllNamed(Routenames.login);
      } catch (e) {
        showSnackBar("Error", "Registration failed: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              onPressed: () => Get.toNamed(Routenames.login),
              icon: const Icon(Icons.arrow_back),
            ),
            const Text("Register"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AuthInput(
                        label: "Farm address",
                        hintText: "Enter farm address",
                        controller: addressController,
                        Validatorcallback:
                            ValidationBuilder().maxLength(300).build(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed:
                          _isFetchingLocation ? null : _getCurrentLocation,
                      icon: _isFetchingLocation
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                      tooltip: 'Get location via GPS',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AuthInput(
                  label: "Phone Number",
                  hintText: "Enter phone number",
                  controller: phoneController,
                  Validatorcallback: ValidationBuilder().phone().build(),
                ),
                const SizedBox(height: 20),
                AuthInput(
                  label: "Farm size",
                  hintText: "Enter farm size in acres",
                  controller: farmsizeController,
                  Validatorcallback:
                      ValidationBuilder().required().maxLength(5).build(),
                ),
                const SizedBox(height: 20),
                AuthInput(
                  label: "Farmer Id",
                  hintText: "Enter your farmer-id",
                  controller: farmidController,
                  Validatorcallback: ValidationBuilder()
                      .maxLength(12)
                      .minLength(12)
                      .required()
                      .build(),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Upload an image of your farm ",
                          style: TextStyle(fontSize: 15)),
                      TextButton(
                        onPressed: controller.pickFarmImage,
                        child: const Text("Upload"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Obx(
                  () => Column(
                    children: [
                      if (controller.farmImage.value != null)
                        FarmerRegistrationPreview(
                          imageFile: controller.farmImage,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Upload an organic certificate",
                          style: TextStyle(fontSize: 15)),
                      TextButton(
                        onPressed: certificatecontroller.certificateImage,
                        child: const Text("Upload"),
                      ),
                    ],
                  ),
                ),
                Obx(
                  () => Column(
                    children: [
                      if (certificatecontroller.certificate.value != null)
                        FarmerRegistrationPreview(
                          imageFile: certificatecontroller.certificate,
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: submit,
                    style: ButtonStyle(
                      minimumSize:
                          WidgetStateProperty.all(const Size.fromHeight(40)),
                    ),
                    child: const Text("Submit"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    addressController.dispose();
    farmsizeController.dispose();
    farmidController.dispose();
    super.dispose();
  }
}
