import 'package:flutter/material.dart';
import 'package:udgaam/models/farmer_request_model.dart';
import 'package:udgaam/views/Admin/widget/details.dart';

class FarmerInfoCard extends StatelessWidget {
  final FarmerRegistration farmer;

  const FarmerInfoCard({super.key, required this.farmer});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FarmerDetailsPage(farmer: farmer),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10.0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image
            // CircleAvatar(
            //   radius: 30,
            //   backgroundImage: farmer.userImage != null
            //       ? NetworkImage(farmer.userImage!)
            //       : const AssetImage('assets/images/default_user.png')
            //           as ImageProvider,
            //   backgroundColor: Colors.white,
            // ),

            const SizedBox(width: 12.0),

            // Farmer Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    farmer.userName ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    farmer.userEmail ?? 'Unknown Email',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    "📍 ${farmer.address}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Status Badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: farmer.status == 'Pending'
                    ? Colors.amber
                    : farmer.status == 'Rejected'
                        ? Colors.red
                        : Colors.green,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                farmer.status,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
