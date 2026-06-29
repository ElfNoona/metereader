import 'reading_model.dart';

class HistoryItemModel {
  final ReadingModel reading;
  final String? billId;
  final bool isPaid;
  final num totalPayable;
  final String? invoiceId;

  HistoryItemModel({
    required this.reading,
    this.billId,
    required this.isPaid,
    required this.totalPayable,
    this.invoiceId,
  });

  factory HistoryItemModel.fromJson(Map<String, dynamic> json) {
    return HistoryItemModel(
      reading: ReadingModel.fromJson(json['reading']),
      billId: json['billId'],
      isPaid: json['isPaid'] ?? false,
      totalPayable: json['totalPayable'] ?? 0.0,
      invoiceId: json['invoiceId'],
    );
  }
}
