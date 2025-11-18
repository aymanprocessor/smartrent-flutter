import 'dart:convert';

DeliveryCheckResponse deliveryCheckResponseFromJson(String str) =>
    DeliveryCheckResponse.fromJson(json.decode(str));

String deliveryCheckResponseToJson(DeliveryCheckResponse data) =>
    json.encode(data.toJson());

class DeliveryCheckResponse {
  String status;
  String message;
  double? distanceKm;
  double? deliveryFee;
  double? maxRadiusKm;
  DeliveryBranch? branch;

  DeliveryCheckResponse({
    required this.status,
    required this.message,
    this.distanceKm,
    this.deliveryFee,
    this.maxRadiusKm,
    this.branch,
  });

  factory DeliveryCheckResponse.fromJson(Map<String, dynamic> json) =>
      DeliveryCheckResponse(
        status: json["status"] ?? 'error',
        message: json["message"] ?? '',
        distanceKm: json["distance_km"] != null
            ? (json["distance_km"]).toDouble()
            : null,
        deliveryFee: json["delivery_fee"] != null
            ? (json["delivery_fee"]).toDouble()
            : null,
        maxRadiusKm: json["max_radius_km"] != null
            ? (json["max_radius_km"]).toDouble()
            : null,
        branch: json["branch"] != null
            ? DeliveryBranch.fromJson(json["branch"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        if (distanceKm != null) "distance_km": distanceKm,
        if (deliveryFee != null) "delivery_fee": deliveryFee,
        if (maxRadiusKm != null) "max_radius_km": maxRadiusKm,
        if (branch != null) "branch": branch?.toJson(),
      };

  bool get isAvailable => status == 'available';
  bool get isUnavailable => status == 'unavailable';
  bool get isError => status == 'error';
}

class DeliveryBranch {
  int id;
  String name;
  String? city;

  DeliveryBranch({
    required this.id,
    required this.name,
    this.city,
  });

  factory DeliveryBranch.fromJson(Map<String, dynamic> json) => DeliveryBranch(
        id: json["id"] ?? 0,
        name: json["name"] ?? '',
        city: json["city"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        if (city != null) "city": city,
      };
}
