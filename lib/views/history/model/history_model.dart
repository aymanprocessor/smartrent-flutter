class HistoryModel {
  Message message;
  Data data;
  String type;

  HistoryModel({required this.message, required this.data, required this.type});

  factory HistoryModel.fromJson(Map<String, dynamic> json) => HistoryModel(
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
  List<History> history;

  Data({required this.history});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    history: List<History>.from(
      json["history"].map((x) => History.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "history": List<dynamic>.from(history.map((x) => x.toJson())),
  };
}

class History {
  int? id;
  int? vendorId;
  int? branchId;
  String? approvedBy;
  DateTime? approvedAt;
  int? carId;
  int? userId;
  String? slug;
  String? phone;
  String? email;
  int? tripId;
  String? location;
  bool? isDeliver;
  String? destination;
  String paymentType;
  String? trxId;
  dynamic amount;
  dynamic charges;
  int distance;
  int rentalDays;
  String pickupTime;
  String? roundPickupTime;
  String? roundPickupDate;
  DateTime pickupDate;
  String message;
  int status;
  DateTime createdAt;
  DateTime updatedAt;
  Cars cars;

  History({
    this.id,
    this.vendorId,
    this.branchId,
    this.approvedBy,
    this.approvedAt,
    this.carId,
    this.userId,
    this.slug,
    this.phone,
    this.email,
    this.tripId,
    this.location,
    this.isDeliver,
    required this.destination,
    required this.paymentType,
    this.trxId,
    required this.amount,
    this.charges,
    required this.distance,
    required this.rentalDays,
    required this.pickupTime,
    this.roundPickupTime,
    required this.pickupDate,
    this.roundPickupDate,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.cars,
  });

  factory History.fromJson(Map<String, dynamic> json) => History(
    id: json["id"],
    vendorId: json["vendor_id"],
    branchId: json["branch_id"],
    approvedBy: json["approved_by"]?.toString(),
    approvedAt: json["approved_at"] == null ? null : DateTime.tryParse(json["approved_at"]),
    carId: json["car_id"],
    userId: json["user_id"],
    slug: json["slug"]?.toString(),
    phone: json["phone"]?.toString(),
    email: json["email"]?.toString(),
    tripId: json["trip_id"],
    location: (json["location"] == null || json["location"].toString().trim().isEmpty)
        ? null
        : json["location"].toString(),
    isDeliver: json["is_deliver"],
    destination: json["destination"],
    paymentType: json["payment_type"],
    trxId: json["trx_id"]?.toString(),
    amount: json["amount"],
    charges: json["charges"],
    distance: json["distance"] ?? 0,
    rentalDays: json["rental_days"] ?? 0,
    pickupTime: json["pickup_time"],
    roundPickupTime: json["round_pickup_time"]?.toString(),
    pickupDate: DateTime.parse(json["pickup_date"]),
    roundPickupDate: json["round_pickup_date"]?.toString(),
    message: json["message"],
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    cars: Cars.fromJson(json["cars"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "vendor_id": vendorId,
    "branch_id": branchId,
    "approved_by": approvedBy,
    "approved_at": approvedAt?.toIso8601String(),
    "car_id": carId,
    "user_id": userId,
    "slug": slug,
    "phone": phone,
    "email": email,
    "trip_id": tripId,
    "location": location,
    "is_deliver": isDeliver,
    "destination": destination,
    "payment_type": paymentType,
    "trx_id": trxId,
    "amount": amount,
    "charges": charges,
    "distance": distance,
    "rental_days": rentalDays,
    "pickup_time": pickupTime,
    "round_pickup_time": roundPickupTime,
    "pickup_date":
        "${pickupDate.year.toString().padLeft(4, '0')}-${pickupDate.month.toString().padLeft(2, '0')}-${pickupDate.day.toString().padLeft(2, '0')}",
    "round_pickup_date": roundPickupDate,
    "message": message,
    "status": status,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "cars": cars.toJson(),
  };
}

class Cars {
  String? carModel;
  String? carNumber;
  String? carType;

  Cars({this.carModel, this.carNumber, this.carType});

  factory Cars.fromJson(Map<String, dynamic> json) {
    // car_model and car_type are present in some responses; fall back to localized titles if needed
    String? model = json["car_model"]?.toString();
    if (model == null) {
      // try to extract from car_title.en.car_title or first available locale
      try {
        final carTitle = json["car_title"] as Map?;
        if (carTitle != null) {
          if (carTitle["en"] != null && carTitle["en"]["car_title"] != null) {
            model = carTitle["en"]["car_title"].toString();
          } else {
            final first = carTitle.values.firstWhere(
              (v) => v is Map && v["car_title"] != null,
              orElse: () => null,
            );
            if (first != null) model = first["car_title"].toString();
          }
        }
      } catch (_) {
        model = null;
      }
    }

    String? type = json["car_type"]?.toString();
    if (type == null) {
      try {
        final t = json["type"] as Map?;
        if (t != null && t["name"] != null) type = t["name"].toString();
      } catch (_) {
        type = null;
      }
    }

    final carNumber = json["car_number"]?.toString();

    return Cars(carModel: model, carNumber: carNumber, carType: type);
  }

  Map<String, dynamic> toJson() => {
    "car_model": carModel,
    "car_number": carNumber,
    "car_type": carType,
  };
}

class Message {
  List<String> success;

  Message({required this.success});

  factory Message.fromJson(Map<String, dynamic> json) {
    List<String> successList = [];
    
    if (json["success"] != null) {
      if (json["success"] is List) {
        successList = List<String>.from(
          json["success"].map((x) => x?.toString() ?? ''),
        );
      } else if (json["success"] is String) {
        successList = [json["success"].toString()];
      }
    }
    
    return Message(success: successList);
  }

  Map<String, dynamic> toJson() => {
    "success": List<dynamic>.from(success.map((x) => x)),
  };
}
