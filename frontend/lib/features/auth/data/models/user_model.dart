class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? flatNumber;
  final String? societyName;
  final String kycStatus;
  final String? avatarUrl;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role = 'user',
    this.flatNumber,
    this.societyName,
    this.kycStatus = 'verified',
    this.avatarUrl,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'user',
      flatNumber: json['flat_number'] as String?,
      societyName: json['society_name'] as String?,
      kycStatus: json['kyc_status'] as String? ?? 'verified',
      avatarUrl: json['avatar_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'flat_number': flatNumber,
      'society_name': societyName,
      'kyc_status': kycStatus,
      'avatar_url': avatarUrl,
      'is_active': isActive,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? flatNumber,
    String? societyName,
    String? kycStatus,
    String? avatarUrl,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      flatNumber: flatNumber ?? this.flatNumber,
      societyName: societyName ?? this.societyName,
      kycStatus: kycStatus ?? this.kycStatus,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}
