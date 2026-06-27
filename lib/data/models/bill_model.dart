class BillModel {
  final String id;
  final String userId;
  final String readingId;
  final DateTime? billingCycleStart;
  final DateTime? billingCycleEnd;
  final num previousReading;
  final num currentReading;
  final num unitsConsumed;
  final num fixedCharges;
  final num gasCharges;
  final num taxAmount;
  final num totalPayable;
  final bool isPaid;

  BillModel({
    required this.id,
    required this.userId,
    required this.readingId,
    this.billingCycleStart,
    this.billingCycleEnd,
    required this.previousReading,
    required this.currentReading,
    required this.unitsConsumed,
    required this.fixedCharges,
    required this.gasCharges,
    required this.taxAmount,
    required this.totalPayable,
    required this.isPaid,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      readingId: json['readingId'] ?? '',
      billingCycleStart: json['billingCycleStart'] != null ? DateTime.tryParse(json['billingCycleStart']) : null,
      billingCycleEnd: json['billingCycleEnd'] != null ? DateTime.tryParse(json['billingCycleEnd']) : null,
      previousReading: json['previousReading'] ?? 0.0,
      currentReading: json['currentReading'] ?? 0.0,
      unitsConsumed: json['unitsConsumed'] ?? 0.0,
      fixedCharges: json['fixedCharges'] ?? 0.0,
      gasCharges: json['gasCharges'] ?? 0.0,
      taxAmount: json['taxAmount'] ?? 0.0,
      totalPayable: json['totalPayable'] ?? 0.0,
      isPaid: json['isPaid'] ?? false,
    );
  }
}
