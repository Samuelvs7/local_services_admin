class ServiceSetting {
  final bool enabled;
  final double commission;
  final double surge;

  ServiceSetting({
    required this.enabled,
    required this.commission,
    this.surge = 1.0,
  });

  ServiceSetting copyWith({bool? enabled, double? commission, double? surge}) {
    return ServiceSetting(
      enabled: enabled ?? this.enabled,
      commission: commission ?? this.commission,
      surge: surge ?? this.surge,
    );
  }

  Map<String, dynamic> toMap() => {
        'enabled': enabled,
        'commission': commission,
        'surge': surge,
      };

  factory ServiceSetting.fromMap(Map<String, dynamic> map) => ServiceSetting(
        enabled: map['enabled'] ?? false,
        commission: (map['commission'] ?? 0.0).toDouble(),
        surge: (map['surge'] ?? 1.0).toDouble(),
      );
}

class CollegeServiceConfig {
  final String collegeId;
  final String collegeName;
  final ServiceSetting food;
  final ServiceSetting bike;
  final ServiceSetting parcel;

  CollegeServiceConfig({
    required this.collegeId,
    required this.collegeName,
    required this.food,
    required this.bike,
    required this.parcel,
  });

  CollegeServiceConfig copyWith({
    ServiceSetting? food,
    ServiceSetting? bike,
    ServiceSetting? parcel,
  }) {
    return CollegeServiceConfig(
      collegeId: collegeId,
      collegeName: collegeName,
      food: food ?? this.food,
      bike: bike ?? this.bike,
      parcel: parcel ?? this.parcel,
    );
  }

  Map<String, dynamic> toMap() => {
        'collegeId': collegeId,
        'collegeName': collegeName,
        'food': food.toMap(),
        'bike': bike.toMap(),
        'parcel': parcel.toMap(),
      };

  factory CollegeServiceConfig.fromMap(Map<String, dynamic> map) =>
      CollegeServiceConfig(
        collegeId: map['collegeId'] ?? '',
        collegeName: map['collegeName'] ?? '',
        food: ServiceSetting.fromMap(map['food'] ?? {}),
        bike: ServiceSetting.fromMap(map['bike'] ?? {}),
        parcel: ServiceSetting.fromMap(map['parcel'] ?? {}),
      );
}
