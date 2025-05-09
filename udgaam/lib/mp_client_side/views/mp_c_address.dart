import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udgaam/models/user_model.dart'; // Adjust path
import 'package:udgaam/services/supabase_service.dart';

class DeliveryDetailsScreen extends StatefulWidget {
  const DeliveryDetailsScreen({super.key});

  @override
  State<DeliveryDetailsScreen> createState() => _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends State<DeliveryDetailsScreen> {
  final _addressFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController homeController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  UserModel? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await SupabaseService.client
            .from('users')
            .select('email, metadata')
            .eq('id', user.id)
            .single();
        setState(() {
          currentUser = UserModel.fromJson(response);
          isLoading = false;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch user data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveAddress() async {
    if (_addressFormKey.currentState!.validate()) {
      final addressString = '${streetController.text}, '
          '${homeController.text.isNotEmpty ? "${homeController.text}, " : ""}'
          'Near ${landmarkController.text}, ${cityController.text}, ${stateController.text}';

      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          List<String> updatedAddresses =
              currentUser?.metadata?.addresses ?? [];
          String updatedDefaultAddress =
              currentUser?.metadata?.defaultAddress ?? '';

          updatedAddresses.add(addressString);
          if (updatedAddresses.length == 1) {
            updatedDefaultAddress = addressString;
          }

          final updatedMetadata = Metadata(
            name: currentUser?.metadata?.name,
            email: currentUser?.metadata?.email,
            role: currentUser?.metadata?.role ?? "User",
            addresses: updatedAddresses,
            defaultAddress: updatedDefaultAddress,
            phoneNumbers: currentUser?.metadata?.phoneNumbers ?? [],
            defaultPhoneNumber: currentUser?.metadata?.defaultPhoneNumber ?? "",
          );

          await SupabaseService.client.from('users').update({
            'metadata': updatedMetadata.toJson(),
          }).eq('id', user.id);

          setState(() {
            currentUser?.metadata = updatedMetadata;
          });

          Get.snackbar('Success', 'Address added successfully!');
          _clearAddressForm();
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to save address: $e');
      }
    }
  }

  Future<void> _savePhoneNumber() async {
    if (_phoneFormKey.currentState!.validate()) {
      final phoneNumber = '+91${phoneController.text}';

      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          List<String> updatedPhoneNumbers =
              currentUser?.metadata?.phoneNumbers ?? [];
          String updatedDefaultPhoneNumber =
              currentUser?.metadata?.defaultPhoneNumber ?? '';

          updatedPhoneNumbers.add(phoneNumber);
          if (updatedPhoneNumbers.length == 1) {
            updatedDefaultPhoneNumber = phoneNumber;
          }

          final updatedMetadata = Metadata(
            name: currentUser?.metadata?.name,
            email: currentUser?.metadata?.email,
            role: currentUser?.metadata?.role ?? "User",
            addresses: currentUser?.metadata?.addresses ?? [],
            defaultAddress: currentUser?.metadata?.defaultAddress ?? "",
            phoneNumbers: updatedPhoneNumbers,
            defaultPhoneNumber: updatedDefaultPhoneNumber,
          );

          await SupabaseService.client.from('users').update({
            'metadata': updatedMetadata.toJson(),
          }).eq('id', user.id);

          setState(() {
            currentUser?.metadata = updatedMetadata;
          });

          Get.snackbar('Success', 'Phone number added successfully!');
          _clearPhoneForm();
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to save phone number: $e');
      }
    }
  }

  Future<void> _setDefaultAddress(String address) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final updatedMetadata = Metadata(
          name: currentUser?.metadata?.name,
          email: currentUser?.metadata?.email,
          role: currentUser?.metadata?.role ?? "User",
          addresses: currentUser?.metadata?.addresses ?? [],
          defaultAddress: address,
          phoneNumbers: currentUser?.metadata?.phoneNumbers ?? [],
          defaultPhoneNumber: currentUser?.metadata?.defaultPhoneNumber ?? "",
        );

        await SupabaseService.client.from('users').update({
          'metadata': updatedMetadata.toJson(),
        }).eq('id', user.id);

        setState(() {
          currentUser?.metadata = updatedMetadata;
        });

        Get.snackbar('Success', 'Default address updated!');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update default address: $e');
    }
  }

  Future<void> _setDefaultPhoneNumber(String phoneNumber) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final updatedMetadata = Metadata(
          name: currentUser?.metadata?.name,
          email: currentUser?.metadata?.email,
          role: currentUser?.metadata?.role ?? "User",
          addresses: currentUser?.metadata?.addresses ?? [],
          defaultAddress: currentUser?.metadata?.defaultAddress ?? "",
          phoneNumbers: currentUser?.metadata?.phoneNumbers ?? [],
          defaultPhoneNumber: phoneNumber,
        );

        await SupabaseService.client.from('users').update({
          'metadata': updatedMetadata.toJson(),
        }).eq('id', user.id);

        setState(() {
          currentUser?.metadata = updatedMetadata;
        });

        Get.snackbar('Success', 'Default phone number updated!');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update default phone number: $e');
    }
  }

  void _clearAddressForm() {
    streetController.clear();
    homeController.clear();
    landmarkController.clear();
    cityController.clear();
    stateController.clear();
  }

  void _clearPhoneForm() {
    phoneController.clear();
  }

  @override
  void dispose() {
    streetController.dispose();
    homeController.dispose();
    landmarkController.dispose();
    cityController.dispose();
    stateController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Details'),
        backgroundColor: Colors.green[700],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Default Address
                    const Text(
                      'Default Address',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentUser?.metadata?.defaultAddress?.isEmpty ?? true
                          ? 'No default address set'
                          : currentUser!.metadata!.defaultAddress!,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 20),

                    // All Addresses
                    const Text(
                      'Your Addresses',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    currentUser?.metadata?.addresses?.isEmpty ?? true
                        ? const Text(
                            'No addresses added yet.',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white70),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: currentUser!.metadata!.addresses!.length,
                            itemBuilder: (context, index) {
                              final address =
                                  currentUser!.metadata!.addresses![index];
                              final isDefault = address ==
                                  currentUser!.metadata!.defaultAddress;
                              return ListTile(
                                title: Text(address,
                                    style:
                                        const TextStyle(color: Colors.white)),
                                trailing: ElevatedButton(
                                  onPressed: isDefault
                                      ? null
                                      : () => _setDefaultAddress(address),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDefault
                                        ? Colors.grey
                                        : Colors.green[700],
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(
                                      isDefault ? 'Default' : 'Set as Default'),
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 20),

                    // Default Phone Number
                    const Text(
                      'Default Phone Number',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentUser?.metadata?.defaultPhoneNumber?.isEmpty ?? true
                          ? 'No default phone number set'
                          : currentUser!.metadata!.defaultPhoneNumber!,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 20),

                    // All Phone Numbers
                    const Text(
                      'Your Phone Numbers',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    currentUser?.metadata?.phoneNumbers?.isEmpty ?? true
                        ? const Text(
                            'No phone numbers added yet.',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white70),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                currentUser!.metadata!.phoneNumbers!.length,
                            itemBuilder: (context, index) {
                              final phone =
                                  currentUser!.metadata!.phoneNumbers![index];
                              final isDefault = phone ==
                                  currentUser!.metadata!.defaultPhoneNumber;
                              return ListTile(
                                title: Text(phone,
                                    style:
                                        const TextStyle(color: Colors.white)),
                                trailing: ElevatedButton(
                                  onPressed: isDefault
                                      ? null
                                      : () => _setDefaultPhoneNumber(phone),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDefault
                                        ? Colors.grey
                                        : Colors.green[700],
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(
                                      isDefault ? 'Default' : 'Set as Default'),
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 20),

                    // Add New Address Form
                    const Text(
                      'Add New Address',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Form(
                      key: _addressFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: streetController,
                            decoration: const InputDecoration(
                              labelText: 'Street',
                              labelStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.white70)),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: (value) =>
                                value!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: homeController,
                            decoration: const InputDecoration(
                              labelText: 'Home Name/Number (Optional)',
                              labelStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.white70)),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: landmarkController,
                            decoration: const InputDecoration(
                              labelText: 'Near Popular Location',
                              labelStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.white70)),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: (value) =>
                                value!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: cityController,
                            decoration: const InputDecoration(
                              labelText: 'City',
                              labelStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.white70)),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: (value) =>
                                value!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: stateController,
                            decoration: const InputDecoration(
                              labelText: 'State',
                              labelStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.white70)),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: (value) =>
                                value!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _saveAddress,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 40),
                            ),
                            child: const Text('Save Address'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Add New Phone Number Form
                    const Text(
                      'Add New Phone Number',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Form(
                      key: _phoneFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number (10 digits)',
                              prefixText: '+91 ',
                              labelStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.white70)),
                            ),
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Required';
                              if (!RegExp(r'^[0-9]{10}$').hasMatch(value))
                                return 'Enter a valid 10-digit number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _savePhoneNumber,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 40),
                            ),
                            child: const Text('Save Phone Number'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      backgroundColor: Colors.grey[850],
    );
  }
}
