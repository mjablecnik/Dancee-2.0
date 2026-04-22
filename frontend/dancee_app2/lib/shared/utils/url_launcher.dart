import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in the platform's default external browser.
/// Does nothing if the URL is null, malformed, or cannot be launched.
Future<void> openUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Opens the platform's default map app centered on [lat]/[lng].
/// Uses a Google Maps web URL that works cross-platform.
Future<void> openMap(double lat, double lng, String label) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
