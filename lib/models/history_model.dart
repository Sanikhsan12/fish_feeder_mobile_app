class HistoryModel {
  final int id;
  final String deviceType;
  final String triggerSource;
  final DateTime startTime;
  final DateTime? endTime;
  final String status;
  final int value;

  HistoryModel({
    required this.id,
    required this.deviceType,
    required this.triggerSource,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.value,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'],
      deviceType: json['deviceType'],
      triggerSource: json['triggerSource'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      status: json['status'],
      value: json['value'],
    );
  }
}
