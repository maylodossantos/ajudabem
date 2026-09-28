import 'package:url_launcher/url_launcher.dart';

import '../geo/geo_point.dart';

abstract interface class ExternalLinkService {
  Future<bool> call(String phone);

  Future<bool> openWhatsApp(String phone);

  Future<bool> email(String address);

  Future<bool> openMap({GeoPoint? point, required String address});
}

class UrlLauncherLinkService implements ExternalLinkService {
  const UrlLauncherLinkService();

  @override
  Future<bool> call(String phone) => _launch(Uri(scheme: 'tel', path: phone));

  @override
  Future<bool> openWhatsApp(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    final withCountry = digits.startsWith('55') ? digits : '55$digits';
    return _launch(Uri.https('wa.me', '/$withCountry'));
  }

  @override
  Future<bool> email(String address) =>
      _launch(Uri(scheme: 'mailto', path: address));

  @override
  Future<bool> openMap({GeoPoint? point, required String address}) {
    final query = point == null
        ? address
        : '${point.latitude},${point.longitude}';
    return _launch(
      Uri.https('www.google.com', '/maps/search/', {
        'api': '1',
        'query': query,
      }),
    );
  }

  Future<bool> _launch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
