import 'package:flutter/material.dart';
import 'package:udgaam/models/farmer_request_model.dart';
import 'package:udgaam/models/user_model.dart';
import 'package:udgaam/services/supabase_service.dart';

class FarmerService {
  Future<List<FarmerRegistration>> getAllFarmers() async {
    try {
      final farmerResponse = await SupabaseService.client
          .from('farmerreg')
          .select('*')
          .order('created_at', ascending: false);

      List<FarmerRegistration> farmers = farmerResponse
          .map<FarmerRegistration>(
            (json) => FarmerRegistration.fromJson(json),
          )
          .toList();

      // Fetch additional user details for each farmer
      for (var farmer in farmers) {
        try {
          final userResponse = await SupabaseService.client
              .from('users')
              .select('*')
              .eq('id', farmer.id)
              .single();

          debugPrint('User response for ${farmer.id}: $userResponse');

          final userData = UserModel.fromJson(userResponse);
          farmer.userName = userData.metadata?.name ?? 'Unknown';
          farmer.userEmail = userData.email ?? 'Unknown Email';
        } catch (userError) {
          debugPrint('Error fetching user data for ${farmer.id}: $userError');
          farmer.userName = 'Unknown';
          farmer.userEmail = 'Unknown Email';
        }
      }

      return farmers;
    } catch (error) {
      debugPrint("Error fetching farmer data: $error");
      rethrow; // Rethrow to let the UI handle the error
    }
  }
}
