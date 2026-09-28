import 'package:geolocator/geolocator.dart';

import '../errors/app_exception.dart';
import '../geo/geo_point.dart';

abstract interface class LocationService {
  Future<GeoPoint> currentPosition();
}

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  static const unavailableMessage =
      'Não foi possível obter sua localização. No navegador ela só funciona '
      'em endereços seguros (https).';

  @override
  Future<GeoPoint> currentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const AppException('Ative a localização do aparelho.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw const AppException(
          'Permita o acesso à localização para ver os pontos próximos.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return GeoPoint(position.latitude, position.longitude);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(unavailableMessage);
    }
  }
}
