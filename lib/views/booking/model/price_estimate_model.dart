class PriceEstimateModel {
  final int carId;
  final int rentalDays;
  final String pricingTier;
  final double rateUsed;
  final double subtotal;
  final double deliveryFee;
  final int taxPercentage;
  final double taxAmount;
  final double total;

  PriceEstimateModel({
    required this.carId,
    required this.rentalDays,
    required this.pricingTier,
    required this.rateUsed,
    required this.subtotal,
    required this.deliveryFee,
    required this.taxPercentage,
    required this.taxAmount,
    required this.total,
  });

  factory PriceEstimateModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    double _d(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0.0;
    int _i(dynamic v) => _d(v).toInt();
    return PriceEstimateModel(
      carId: _i(data['car_id']),
      rentalDays: _i(data['rental_days']),
      pricingTier: data['pricing_tier']?.toString() ?? '',
      rateUsed: _d(data['rate_used']),
      subtotal: _d(data['subtotal']),
      deliveryFee: _d(data['delivery_fee']),
      taxPercentage: _i(data['tax_percentage']),
      taxAmount: _d(data['tax_amount']),
      total: _d(data['total']),
    );
  }
}
