class ExtractionHistory {
  final String fileName;
  final String destination;
  final DateTime extractedAt;

  ExtractionHistory({
    required this.fileName,
    required this.destination,
    required this.extractedAt,
  });

  String toJson() {
    return '$fileName|$destination|${extractedAt.toIso8601String()}';
  }

  factory ExtractionHistory.fromJson(String json) {
    final parts = json.split('|');
    return ExtractionHistory(
      fileName: parts[0],
      destination: parts[1],
      extractedAt: DateTime.parse(parts[2]),
    );
  }
}

