class CarBranch {
  final int id;
  final String? name;
  final String? address;
  final String? city;
  final String? phone;
  final String? email;

  const CarBranch({
    required this.id,
    this.name,
    this.address,
    this.city,
    this.phone,
    this.email,
  });

  factory CarBranch.fromJson(Map<String, dynamic> json) => CarBranch(
    id: json['id'] as int,
    name: json['name']?.toString(),
    address: json['address']?.toString(),
    city: json['city']?.toString(),
    phone: json['phone']?.toString(),
    email: json['email']?.toString(),
  );
}

class CarBranchResponseModel {
  final CarBranch branch;

  const CarBranchResponseModel({required this.branch});

  factory CarBranchResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final branchJson = data?['branch'] as Map<String, dynamic>?;
    if (branchJson == null) throw const FormatException('missing branch in response');
    return CarBranchResponseModel(branch: CarBranch.fromJson(branchJson));
  }
}
