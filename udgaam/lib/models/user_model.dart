class UserModel {
  String? id;
  String? email;
  String? createdAt;
  String? role;
  Metadata? metadata;

  UserModel({this.email, this.metadata, this.createdAt, this.id, this.role});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    createdAt = json['created_at'];
    role = json['role'];
    metadata =
        json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['created_at'] = createdAt;
    data['role'] = role;
    if (metadata != null) {
      data['metadata'] = metadata!.toJson();
    }
    return data;
  }
}

class Metadata {
  String? sub;
  String? name;
  String? email;
  String? image;
  String? description;
  String? role;
  bool? emailVerified;
  bool? phoneVerified;
  List<String>? addresses;
  String? defaultAddress;
  List<String>? phoneNumbers;
  String? defaultPhoneNumber;

  Metadata({
    this.sub,
    this.name,
    this.email,
    this.image,
    this.description,
    this.role = "User",
    this.emailVerified,
    this.phoneVerified,
    this.addresses = const [],
    this.defaultAddress = "",
    this.phoneNumbers = const [],
    this.defaultPhoneNumber = "",
  });

  Metadata.fromJson(Map<String, dynamic> json) {
    sub = json['sub'];
    name = json['name'];
    email = json['email'];
    image = json['image'];
    description = json['description'];
    role = json['role'] ?? "User";
    emailVerified = json['email_verified'];
    phoneVerified = json['phone_verified'];
    addresses =
        json['addresses'] != null ? List<String>.from(json['addresses']) : [];
    defaultAddress = json['default_address'] ?? "";
    phoneNumbers = json['phone_numbers'] != null
        ? List<String>.from(json['phone_numbers'])
        : [];
    defaultPhoneNumber = json['default_phone_number'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sub'] = sub;
    data['name'] = name;
    data['email'] = email;
    data['image'] = image;
    data['description'] = description;
    data['role'] = role;
    data['email_verified'] = emailVerified;
    data['phone_verified'] = phoneVerified;
    data['addresses'] = addresses;
    data['default_address'] = defaultAddress;
    data['phone_numbers'] = phoneNumbers;
    data['default_phone_number'] = defaultPhoneNumber;
    return data;
  }
}
