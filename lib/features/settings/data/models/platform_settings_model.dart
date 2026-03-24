class PlatformSettings {
  final String platformName;
  final String tagline;
  final String supportEmail;
  
  // Feature Flags
  final bool foodDelivery;
  final bool bikeRental;
  final bool parcelDelivery;
  final bool pushNotifications;
  final bool vendorDashboard;
  final bool analytics;

  PlatformSettings({
    required this.platformName,
    required this.tagline,
    required this.supportEmail,
    required this.foodDelivery,
    required this.bikeRental,
    required this.parcelDelivery,
    required this.pushNotifications,
    required this.vendorDashboard,
    required this.analytics,
  });

  factory PlatformSettings.fromMap(Map<String, dynamic> map) {
    return PlatformSettings(
      platformName: map['platformName'] ?? 'NexSus',
      tagline: map['tagline'] ?? 'Hyperlocal Campus Delivery',
      supportEmail: map['supportEmail'] ?? 'support@nexsus.in',
      foodDelivery: map['foodDelivery'] ?? true,
      bikeRental: map['bikeRental'] ?? true,
      parcelDelivery: map['parcelDelivery'] ?? true,
      pushNotifications: map['pushNotifications'] ?? true,
      vendorDashboard: map['vendorDashboard'] ?? true,
      analytics: map['analytics'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'platformName': platformName,
      'tagline': tagline,
      'supportEmail': supportEmail,
      'foodDelivery': foodDelivery,
      'bikeRental': bikeRental,
      'parcelDelivery': parcelDelivery,
      'pushNotifications': pushNotifications,
      'vendorDashboard': vendorDashboard,
      'analytics': analytics,
    };
  }

  PlatformSettings copyWith({
    String? platformName,
    String? tagline,
    String? supportEmail,
    bool? foodDelivery,
    bool? bikeRental,
    bool? parcelDelivery,
    bool? pushNotifications,
    bool? vendorDashboard,
    bool? analytics,
  }) {
    return PlatformSettings(
      platformName: platformName ?? this.platformName,
      tagline: tagline ?? this.tagline,
      supportEmail: supportEmail ?? this.supportEmail,
      foodDelivery: foodDelivery ?? this.foodDelivery,
      bikeRental: bikeRental ?? this.bikeRental,
      parcelDelivery: parcelDelivery ?? this.parcelDelivery,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      vendorDashboard: vendorDashboard ?? this.vendorDashboard,
      analytics: analytics ?? this.analytics,
    );
  }
}
