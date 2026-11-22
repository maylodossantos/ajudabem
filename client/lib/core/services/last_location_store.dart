import 'package:shared_preferences/shared_preferences.dart';

import '../geo/geo_point.dart';

abstract interface class LastLocationStore {
  Future<GeoPoint?> read();

  Future<void> save(GeoPoint point);
}

class SharedPrefsLastLocationStore implements LastLocationStore {
  const SharedPrefsLastLocationStore();

  static const _latitude = 'last_location_latitude';
  static const _longitude = 'last_location_longitude';

  @override
  Future<GeoPoint?> read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final latitude = prefs.getDouble(_latitude);
      final longitude = prefs.getDouble(_longitude);
      if (latitude == null || longitude == null) return null;
      return GeoPoint(latitude, longitude);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(GeoPoint point) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_latitude, point.latitude);
      await prefs.setDouble(_longitude, point.longitude);
    } catch (_) {
      return;
    }
  }
}
