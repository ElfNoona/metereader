class UserModel {
  final String id;
  final String username;
  final String fullName;
  final String bpNumber;
  final String address;

  UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.bpNumber,
    required this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      bpNumber: json['bpNumber'] ?? json['accountNo'] ?? '',
      address: json['address'] ?? '',
    );
  }
}
