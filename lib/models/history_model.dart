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
      deviceType: json['device_type'],
      triggerSource: json['trigger_source'],
      startTime: DateTime.parse(json['start_time']).toLocal(),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time']).toLocal()
          : null,
      status: json['status'],
      value: json['value'],
    );
  }
}
