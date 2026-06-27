class ReadingModel {
  final String id;
  final String userId;
  final num readingValue;
  final String? rawOcrValue;
  final num? confidenceScore;
  final DateTime? timestamp;
  final bool isAutoDetected;
  final String status;
  final String? imageUrl;

  ReadingModel({
    required this.id,
    required this.userId,
    required this.readingValue,
    this.rawOcrValue,
    this.confidenceScore,
    this.timestamp,
    required this.isAutoDetected,
    required this.status,
    this.imageUrl,
  });

  factory ReadingModel.fromJson(Map<String, dynamic> json) {
    return ReadingModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      readingValue: json['readingValue'] ?? 0.0,
      rawOcrValue: json['rawOcrValue'],
      confidenceScore: json['confidenceScore'],
      timestamp: json['timestamp'] != null ? DateTime.tryParse(json['timestamp']) : null,
      isAutoDetected: json['isAutoDetected'] ?? true,
      status: json['status'] ?? 'Pending Verification',
      imageUrl: json['imageUrl'],
    );
  }
}
