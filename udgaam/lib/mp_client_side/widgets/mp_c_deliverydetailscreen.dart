import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udgaam/models/user_model.dart';
import 'package:udgaam/services/supabase_service.dart';

class DeliveryDetailsScreen extends StatefulWidget {
  const DeliveryDetailsScreen({super.key});

  @override
  State<DeliveryDetailsScreen> createState() => _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends State<DeliveryDetailsScreen> {
  final _addressFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();
  final TextEditingController addressController = TextEditingController();
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
          addressController.text = currentUser?.metadata?.defaultAddress ?? '';
          phoneController.text = currentUser?.metadata?.defaultPhoneNumber
                  ?.replaceFirst('+91', '') ??
              '';
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user data: $e')),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveDetails() async {
    if (_addressFormKey.currentState!.validate() &&
        _phoneFormKey.currentState!.validate()) {
      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          final updatedMetadata = Metadata(
            name: currentUser?.metadata?.name,
            email: currentUser?.metadata?.email,
            role: currentUser?.metadata?.role ?? "User",
            defaultAddress: addressController.text,
            defaultPhoneNumber: '+91${phoneController.text}',
          );

          await SupabaseService.client.from('users').update({
            'metadata': updatedMetadata.toJson(),
          }).eq('id', user.id);

          setState(() {
            currentUser?.metadata = updatedMetadata;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Details saved successfully!')),
          );
          Navigator.pop(context); // Return to previous screen
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save details: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    addressController.dispose();
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
                    const Text(
                      'Delivery Address',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Form(
                      key: _addressFormKey,
                      child: TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: 'Enter Full Address',
                          labelStyle: TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70)),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) =>
                            value!.isEmpty ? 'Address is required' : null,
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Phone Number',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Form(
                      key: _phoneFormKey,
                      child: TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number (10 digits)',
                          prefixText: '+91 ',
                          labelStyle: TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70)),
                        ),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Phone number is required';
                          if (!RegExp(r'^[0-9]{10}$').hasMatch(value))
                            return 'Enter a valid 10-digit number';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 40),
                      ),
                      child: const Text('Save Details'),
                    ),
                  ],
                ),
              ),
            ),
      backgroundColor: Colors.grey[850],
    );
  }
}
