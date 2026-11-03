class DashboardInfoModel {
  Message message;
  Data data;
  String type;

  DashboardInfoModel({
    required this.message,
    required this.data,
    required this.type,
  });

  factory DashboardInfoModel.fromJson(Map<String, dynamic> json) =>
      DashboardInfoModel(
        message: Message.fromJson(json["message"]),
        data: Data.fromJson(json["data"]),
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
    "message": message.toJson(),
    "data": data.toJson(),
    "type": type,
  };
}

class Data {
  Instructions instructions;
  DataUserInfo userInfo;
  ProfileImagePaths profileImagePaths;
  int roundTrips;
  int bookingRejects;
  int rideComplete;

  Data({
    required this.instructions,
    required this.userInfo,
    required this.profileImagePaths,
    required this.roundTrips,
    required this.bookingRejects,
    required this.rideComplete,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    instructions: Instructions.fromJson(json["instructions"]),
    userInfo: DataUserInfo.fromJson(json["user_info"]),
    profileImagePaths: ProfileImagePaths.fromJson(json["profile_image_paths"]),
    roundTrips: json["round_trips"],
    bookingRejects: json["booking_rejects"],
    rideComplete: json["ride_complete"],
  );

  Map<String, dynamic> toJson() => {
    "instructions": instructions.toJson(),
    "user_info": userInfo.toJson(),
    "profile_image_paths": profileImagePaths.toJson(),
    "round_trips": roundTrips,
    "booking_rejects": bookingRejects,
    "ride_complete": rideComplete,
  };
}

class Instructions {
  InstructionsUserInfo userInfo;

  Instructions({required this.userInfo});

  factory Instructions.fromJson(Map<String, dynamic> json) =>
      Instructions(userInfo: InstructionsUserInfo.fromJson(json["user_info"]));

  Map<String, dynamic> toJson() => {"user_info": userInfo.toJson()};
}

class InstructionsUserInfo {
  String kycVerified;

  InstructionsUserInfo({required this.kycVerified});

  factory InstructionsUserInfo.fromJson(Map<String, dynamic> json) =>
      InstructionsUserInfo(kycVerified: json["kyc_verified"]);

  Map<String, dynamic> toJson() => {"kyc_verified": kycVerified};
}

class ProfileImagePaths {
  String baseUrl;
  String pathLocation;
  String defaultImage;

  ProfileImagePaths({
    required this.baseUrl,
    required this.pathLocation,
    required this.defaultImage,
  });

  factory ProfileImagePaths.fromJson(Map<String, dynamic> json) =>
      ProfileImagePaths(
        baseUrl: json["base_url"],
        pathLocation: json["path_location"],
        defaultImage: json["default_image"],
      );

  Map<String, dynamic> toJson() => {
    "base_url": baseUrl,
    "path_location": pathLocation,
    "default_image": defaultImage,
  };
}

class DataUserInfo {
  int id;
  String firstname;
  String lastname;
  String fullname;
  String username;
  String email;
  dynamic image;
  dynamic mobileCode;
  dynamic mobile;
  dynamic fullMobile;
  int emailVerified;
  int kycVerified;
  int twoFactorVerified;
  int twoFactorStatus;
  dynamic twoFactorSecret;
  String? nationalIdImage;
  String? drivingLicenseImage;
  String? nationalIdImageUrl;
  String? drivingLicenseImageUrl;
  bool hasNationalId;
  bool hasDrivingLicense;
  bool hasRequiredDocuments;

  DataUserInfo({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.fullname,
    required this.username,
    required this.email,
    required this.image,
    required this.mobileCode,
    required this.mobile,
    required this.fullMobile,
    required this.emailVerified,
    required this.kycVerified,
    required this.twoFactorVerified,
    required this.twoFactorStatus,
    required this.twoFactorSecret,
    this.nationalIdImage,
    this.drivingLicenseImage,
    this.nationalIdImageUrl,
    this.drivingLicenseImageUrl,
    this.hasNationalId = false,
    this.hasDrivingLicense = false,
    this.hasRequiredDocuments = false,
  });

  factory DataUserInfo.fromJson(Map<String, dynamic> json) => DataUserInfo(
    id: json["id"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    fullname: json["fullname"],
    username: json["username"],
    email: json["email"],
    image: json["image"],
    mobileCode: json["mobile_code"],
    mobile: json["mobile"],
    fullMobile: json["full_mobile"],
    emailVerified: json["email_verified"],
    kycVerified: json["kyc_verified"],
    twoFactorVerified: json["two_factor_verified"],
    twoFactorStatus: json["two_factor_status"],
    twoFactorSecret: json["two_factor_secret"],
    nationalIdImage: json["national_id_image"],
    drivingLicenseImage: json["driving_license_image"],
    nationalIdImageUrl: json["national_id_image_url"] ?? json["nationalIdImageUrl"],
    drivingLicenseImageUrl: json["driving_license_image_url"] ?? json["drivingLicenseImageUrl"],
    hasNationalId: json["has_national_id"] == true ||
        (json["national_id_image"] != null &&
            json["national_id_image"].toString().isNotEmpty),
    hasDrivingLicense: json["has_driving_license"] == true ||
        (json["driving_license_image"] != null &&
            json["driving_license_image"].toString().isNotEmpty),
    hasRequiredDocuments: json["has_required_documents"] == true ||
        ((json["national_id_image"] != null &&
                json["national_id_image"].toString().isNotEmpty) &&
            (json["driving_license_image"] != null &&
                json["driving_license_image"].toString().isNotEmpty)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstname": firstname,
    "lastname": lastname,
    "fullname": fullname,
    "username": username,
    "email": email,
    "image": image,
    "mobile_code": mobileCode,
    "mobile": mobile,
    "full_mobile": fullMobile,
    "email_verified": emailVerified,
    "kyc_verified": kycVerified,
    "two_factor_verified": twoFactorVerified,
    "two_factor_status": twoFactorStatus,
    "two_factor_secret": twoFactorSecret,
    "national_id_image": nationalIdImage,
    "driving_license_image": drivingLicenseImage,
    "national_id_image_url": nationalIdImageUrl,
    "driving_license_image_url": drivingLicenseImageUrl,
    "has_national_id": hasNationalId,
    "has_driving_license": hasDrivingLicense,
    "has_required_documents": hasRequiredDocuments,
  };
}

class Message {
  List<String> success;

  Message({required this.success});

  factory Message.fromJson(Map<String, dynamic> json) =>
      Message(success: List<String>.from(json["success"].map((x) => x)));

  Map<String, dynamic> toJson() => {
    "success": List<dynamic>.from(success.map((x) => x)),
  };
}
