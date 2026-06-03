// lib/data/calendar_service_web.dart
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
String? getCodeFromCurrentUrl() {
  final uri = Uri.parse(html.window.location.href);
  return uri.queryParameters['code'];
}
void redirectToUrl(String url) {
  html.window.location.href = url;
}
// calendar_service_web.dart — додай:
String getCurrentUrl() => html.window.location.href;
void cleanUrl() {
  html.window.history.replaceState(null, '', '/');
}