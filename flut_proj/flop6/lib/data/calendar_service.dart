import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'calendar_service_web.dart'
    if (dart.library.io) 'calendar_service_io.dart' as platform;
import 'local_storage_service.dart';
import 'database_service.dart';
import 'models/post.dart';

class CalendarService {
  CalendarService._();

  static const _scopes = [
    'https://www.googleapis.com/auth/calendar.events',
    'https://www.googleapis.com/auth/userinfo.email',
    'https://www.googleapis.com/auth/userinfo.profile',
    'openid',
  ];

  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static Future<bool> signIn() async {
    try {
      if (kIsWeb) {
        return await _signInWeb();
      }
      return false;
    } catch (e) {
      debugPrint('signIn error: $e');
      return false;
    }
  }

  static Future<bool> _signInWeb() async {
    final code = platform.getCodeFromCurrentUrl();

    if (code != null) {
      return await _handleAuthCode(code);
    } else {
      _redirectToGoogle();
      return false;
    }
  }

  static void _redirectToGoogle() {
    final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'client_id':     _clientId,
      'redirect_uri':  _redirectUri,
      'response_type': 'code',
      'scope':         _scopes.join(' '),
      'access_type':   'offline',
      'prompt':        'consent',
    }).toString();

    platform.redirectToUrl(authUrl);
  }

  static Future<bool> _handleAuthCode(String code) async {
    platform.cleanUrl();

    final tokens = await _exchangeCodeForTokens(code);
    if (tokens == null) return false;

    await _fetchAndSaveProfile(tokens['access_token']!);
    return true;
  }
  static Future<Map<String, String>?> _exchangeCodeForTokens(String code) async {
    try {
      final response = await _dio.post(
        'https://oauth2.googleapis.com/token',
        data: {
          'code':          code,
          'client_id':     _clientId,
          'client_secret': _clientSecret,
          'redirect_uri':  _redirectUri,
          'grant_type':    'authorization_code',
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final data = response.data as Map<String, dynamic>;

      final expiry = DateTime.now().add(
        Duration(seconds: data['expires_in'] as int),
      );
      await LocalStorageService.saveTokens(
        accessToken:  data['access_token']  as String,
        refreshToken: data['refresh_token'] as String? ?? '',
        expiry:       expiry,
      );

      return {
        'access_token':  data['access_token'] as String,
        'refresh_token': data['refresh_token'] as String? ?? '',
      };
    } on DioException catch (e) {
      debugPrint('Token exchange error: ${e.response?.data}');
      return null;
    }
  }

  static Future<String?> _refreshAccessToken() async {
    final refreshToken = LocalStorageService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      final response = await _dio.post(
        'https://oauth2.googleapis.com/token',
        data: {
          'refresh_token': refreshToken,
          'client_id':     _clientId,
          'client_secret': _clientSecret,
          'grant_type':    'refresh_token',
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final data = response.data as Map<String, dynamic>;
      final expiry = DateTime.now().add(
        Duration(seconds: data['expires_in'] as int),
      );

      await LocalStorageService.saveTokens(
        accessToken:  data['access_token'] as String,
        refreshToken: refreshToken,
        expiry:       expiry,
      );

      return data['access_token'] as String;
    } on DioException catch (e) {
      debugPrint('Token refresh error: ${e.response?.data}');
      return null;
    }
  }

  static Future<String?> _getValidToken() async {
    if (LocalStorageService.hasValidToken) {
      return LocalStorageService.getAccessToken();
    }
    return _refreshAccessToken();
  }

  static Future<void> _fetchAndSaveProfile(String accessToken) async {
    try {
      final response = await _dio.get(
        'https://www.googleapis.com/oauth2/v2/userinfo',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final data = response.data as Map<String, dynamic>;

      await LocalStorageService.saveGoogleProfile(
        googleId: data['id']         as String,
        name:     data['name']       as String,
        email:    data['email']      as String,
        photoUrl: data['picture']    as String? ?? '',
      );

      await DatabaseService.saveGoogleProfile(
        googleId: data['id']   as String,
        name:     data['name'] as String,
        email:    data['email'] as String,
      );
    } on DioException catch (e) {
      debugPrint('Profile fetch error: ${e.response?.data}');
    }
  }

  static Future<CalendarResult> addEventToCalendar(Post post) async {
    if (post.eventDate == null) {
      return CalendarResult.failure('Event date is not set for this post');
    }

    final token = await _getValidToken();
    if (token == null) {
      return CalendarResult.failure('Not authenticated');
    }

    try {
      final eventBody = {
        'summary':     post.title,
        'description': post.body,
        'start': {
          'dateTime': post.eventDate!.toUtc().toIso8601String(),
          'timeZone': 'Europe/Kyiv',
        },
        'end': {
          'dateTime': post.eventDate!
              .add(const Duration(hours: 2))
              .toUtc()
              .toIso8601String(),
          'timeZone': 'Europe/Kyiv',
        },
        'reminders': {
          'useDefault': false,
          'overrides': [
            {'method': 'popup', 'minutes': 60},
            {'method': 'email', 'minutes': 1440},
          ],
        },
      };

      final response = await _dio.post(
        'https://www.googleapis.com/calendar/v3/calendars/primary/events',
        data: jsonEncode(eventBody),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type':  'application/json',
          },
        ),
      );

      final createdEvent = response.data as Map<String, dynamic>;
      final eventId = createdEvent['id'] as String;
      final eventLink = createdEvent['htmlLink'] as String;

      debugPrint('Подія створена: $eventLink');
      return CalendarResult.success(eventId: eventId, eventLink: eventLink);

    } on DioException catch (e) {
      final message = _parseDioError(e);
      debugPrint('Calendar API error: $message');
      return CalendarResult.failure(message);
    }
  }

  static Future<void> signOut() async {
    final token = LocalStorageService.getAccessToken();

    if (token != null && token.isNotEmpty) {
      try {
        await _dio.post(
          'https://oauth2.googleapis.com/revoke',
          queryParameters: {'token': token},
        );
      } catch (_) {
      }
    }

    await LocalStorageService.clearAll();
    await DatabaseService.disconnectGoogle();
  }

  static String _parseDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] is Map) {
      return data['error']['message'] as String? ?? 'Unknown error';
    }
    return e.message ?? 'Error: ${e.type}';
  }
  static void _openUrlInBrowser(String url) {
    debugPrint('Open $url');
  }
}

class CalendarResult {
  final bool isSuccess;
  final String? eventId;
  final String? eventLink;
  final String? errorMessage;

  const CalendarResult._({
    required this.isSuccess,
    this.eventId,
    this.eventLink,
    this.errorMessage,
  });

  factory CalendarResult.success({
    required String eventId,
    required String eventLink,
  }) => CalendarResult._(
    isSuccess: true,
    eventId: eventId,
    eventLink: eventLink,
  );

  factory CalendarResult.failure(String message) => CalendarResult._(
    isSuccess: false,
    errorMessage: message,
  );
}