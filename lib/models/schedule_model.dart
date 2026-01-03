class FeederScheduleModel {
  final int id;
  final String dayName;
  final String time;
  final int amountGram;
  final bool isActive;

  FeederScheduleModel({
    required this.id,
    required this.dayName,
    required this.time,
    required this.amountGram,
    required this.isActive,
  });

  factory FeederScheduleModel.fromJson(Map<String, dynamic> json) {
    return FeederScheduleModel(
      id: json['id'],
      dayName: json['day_name'],
      time: json['time'],
      amountGram: json['amount_gram'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'day_name': dayName,
        'time': time,
        'amount_gram': amountGram,
        'is_active': isActive,
      };
}

class UVScheduleModel {
  final int id;
  final String dayName;
  final String startTime;
  final String endTime;
  final bool isActive;

  UVScheduleModel({
    required this.id,
    required this.dayName,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

  factory UVScheduleModel.fromJson(Map<String, dynamic> json) {
    return UVScheduleModel(
      id: json['id'],
      dayName: json['day_name'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'day_name': dayName,
        'start_time': startTime,
        'end_time': endTime,
        'is_active': isActive,
      };
}
