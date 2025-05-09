class FarmerRegistration {
  final String id;
  final DateTime createdAt;
  final String number;
  final String address;
  final String farmSize;
  final String farmerId;
  final String farmImage;
  final String certificate;
  final String status;

  // New Fields for User Data
  String? userName;
  String? userEmail;

  FarmerRegistration({
    required this.id,
    required this.createdAt,
    required this.number,
    required this.address,
    required this.farmSize,
    required this.farmerId,
    required this.farmImage,
    required this.certificate,
    required this.status,
    this.userName,
    this.userEmail,
  });

  factory FarmerRegistration.fromJson(Map<String, dynamic> json) {
    return FarmerRegistration(
      id: json['id'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      number: json['number'].toString(),
      address: json['address'] ?? '',
      farmSize: json['farmsize'].toString(),
      farmerId: json['farmerId'].toString(),
      farmImage: json['farmImage'] ?? '',
      certificate: json['certificate'] ?? '',
      status: json['status'] ?? 'Pending',
    );
  }

  get name => null;

  copyWith({required String farmerId}) {}
}
