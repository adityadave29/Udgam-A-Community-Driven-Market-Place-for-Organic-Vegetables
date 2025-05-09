import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:form_validator/form_validator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udgaam/controllers/farmer_registration.dart';
import 'package:udgaam/services/supabase_service.dart';
import 'package:udgaam/utils/env.dart';
import 'package:udgaam/utils/helper.dart';
import 'package:udgaam/widgets/auth_input.dart';
import 'package:udgaam/widgets/registration_image_preview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:udgaam/routes/route_names.dart';

class UpdateDetailsScreen extends StatefulWidget {
  const UpdateDetailsScreen({super.key});

  @override
  State<UpdateDetailsScreen> createState() => _UpdateDetailsScreenState();
}

class _UpdateDetailsScreenState extends State<UpdateDetailsScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController farmsizeController = TextEditingController();
  final TextEditingController farmidController = TextEditingController();

  final FarmerRegiatrationController controller =
      Get.put(FarmerRegiatrationController(), tag: 'farmImage');
  final FarmerRegiatrationController certificateController =
      Get.put(FarmerRegiatrationController(), tag: 'certificate');
  bool _isFetchingLocation = false;
  String? existingFarmImagePath;
  String? existingCertificatePath;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndLoad();
  }

  Future<void> _checkAuthenticationAndLoad() async {
    final String farmerId = Get.arguments?['farmerId'] ?? '';
    final userId = SupabaseService.client.auth.currentUser?.id;

    if (userId == null) {
      showSnackBar("Error", "You must be logged in to update details");
      Get.offAllNamed(Routenames.login);
      return;
    }

    if (userId != farmerId) {
      showSnackBar("Error", "You are not authorized to update this record");
      Get.back();
      return;
    }

    await _loadExistingDetails();
  }

  Future<void> _loadExistingDetails() async {
    final String farmerId = Get.arguments?['farmerId'] ?? '';
    if (farmerId.isEmpty) {
      showSnackBar("Error", "No farmer ID provided.");
      return;
    }

    try {
      final response = await SupabaseService.client
          .from('farmerreg')
          .select()
          .eq('id', farmerId)
          .maybeSingle();

      if (response != null) {
        setState(() {
          phoneController.text = response['number']?.toString() ?? '';
          addressController.text = response['address']?.toString() ?? '';
          farmsizeController.text = response['farmsize']?.toString() ?? '';
          farmidController.text = response['farmerId']?.toString() ?? '';
          existingFarmImagePath = response['farmImage'];
          existingCertificatePath = response['certificate'];
        });
      } else {
        showSnackBar("Warning", "No existing details found for this farmer.");
      }
    } catch (e) {
      showSnackBar("Error", "Failed to load existing details: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isFetchingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await _showLocationServiceDialog();
        setState(() => _isFetchingLocation = false);
        return;
      }

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
        showSnackBar("Error", "Location permissions are permanently denied.");
        setState(() => _isFetchingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

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
              onPressed: () => Navigator.of(context).pop(),
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

  Future<void> _updateDetails(String farmerId) async {
    if (_form.currentState!.validate()) {
      try {
        final userId = SupabaseService.client.auth.currentUser?.id;
        if (userId == null) {
          showSnackBar("Error", "You must be logged in to update details");
          Get.offAllNamed(Routenames.login);
          return;
        }

        if (userId != farmerId) {
          showSnackBar("Error",
              "You are not authorized to update this farmer's details");
          return;
        }

        String farmImagePath = existingFarmImagePath ?? "";
        String certificatePath = existingCertificatePath ?? "";

        if (controller.farmImage.value != null &&
            controller.farmImage.value!.existsSync()) {
          farmImagePath = await SupabaseService.client.storage
              .from(Env.s3Bucket)
              .upload("$farmerId/farm.png", controller.farmImage.value!,
                  fileOptions: const FileOptions(upsert: true));
        }

        if (certificateController.certificate.value != null &&
            certificateController.certificate.value!.existsSync()) {
          certificatePath = await SupabaseService.client.storage
              .from(Env.s3Bucket)
              .upload("$farmerId/certificate.png",
                  certificateController.certificate.value!,
                  fileOptions: const FileOptions(upsert: true));
        }

        await SupabaseService.client.from("farmerreg").update({
          "number": phoneController.text,
          "address": addressController.text,
          "farmsize": farmsizeController.text,
          "farmerId": farmidController.text,
          "farmImage": farmImagePath.isNotEmpty ? farmImagePath : null,
          "certificate": certificatePath.isNotEmpty ? certificatePath : null,
          "status": "Pending",
        }).eq("id", farmerId);

        showSnackBar("Success", "Details updated successfully");
        Get.back(); // Return to RejectionReasonScreen
      } on PostgrestException catch (e) {
        if (e.code == '42501' || e.code == '403') {
          showSnackBar("Error",
              "Unauthorized: You don't have permission to update this record");
        } else {
          showSnackBar("Error", "Update failed: ${e.message}");
        }
      } catch (e) {
        showSnackBar("Error", "Update failed: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String farmerId = Get.arguments?['farmerId'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              onPressed: () => Get.back(), // Go back to RejectionReasonScreen
              icon: const Icon(Icons.arrow_back),
            ),
            const Text("Update Details"),
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
                      const Text("Upload an image of your farm",
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
                        )
                      else if (existingFarmImagePath != null)
                        Column(
                          children: [
                            Image.network(
                              SupabaseService.client.storage
                                  .from(Env.s3Bucket)
                                  .getPublicUrl(
                                      existingFarmImagePath!.split('/').last),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ],
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
                        onPressed: certificateController.certificateImage,
                        child: const Text("Upload"),
                      ),
                    ],
                  ),
                ),
                Obx(
                  () => Column(
                    children: [
                      if (certificateController.certificate.value != null)
                        FarmerRegistrationPreview(
                          imageFile: certificateController.certificate,
                        )
                      else if (existingCertificatePath != null)
                        Column(
                          children: [
                            Image.network(
                              SupabaseService.client.storage
                                  .from(Env.s3Bucket)
                                  .getPublicUrl(
                                      existingCertificatePath!.split('/').last),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () => _updateDetails(farmerId),
                    style: ButtonStyle(
                      minimumSize:
                          WidgetStateProperty.all(const Size.fromHeight(40)),
                    ),
                    child: const Text("Update"),
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
