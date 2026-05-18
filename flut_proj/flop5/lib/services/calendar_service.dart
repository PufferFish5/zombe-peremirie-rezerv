import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class GoogleCalendarService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '1085287638398-q25cthqu31ib4a6ctj7besivk4o8rn44.apps.googleusercontent.com',
    scopes: <String>[
      'https://www.googleapis.com/auth/calendar.events',
    ],
  );

  Future<String?> getAccessToken() async {
    try {
      final GoogleSignInAccount? user = await _googleSignIn.signIn();
      if (user == null) return null;

      final auth = await user.authentication;
      return auth.accessToken;
    } catch (e) {
      print('Google Sign-In error: $e');
      return null;
    }
  }
  String? getCurrentUserPhoto() => _googleSignIn.currentUser?.photoUrl;

  Future<String?> insertEvent(Task task, String token) async {
    final url = Uri.parse('https://www.googleapis.com/calendar/v3/calendars/primary/events');

    try {
      print('Inserting event: ${task.title} at ${task.date}');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'summary': '[Task] ${task.title}',
          'description': 'Категорія: ${task.category}\n${task.description}',
          'start': {
            'dateTime': task.date.toUtc().toIso8601String(),
          },
          'end': {
            'dateTime': task.date.add(const Duration(hours: 1)).toUtc().toIso8601String(),
          },
        }),
      );
      print('Google Calendar API response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Event created successfully!');
        return data['id'];
      } else {
        print('Google Calendar API Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error creating event: $e');
      return null;
    }
  }

  Future<String?> getExistingToken() async {

    if (_googleSignIn.currentUser != null) {
      final auth = await _googleSignIn.currentUser!.authentication;
      return auth.accessToken;
    }
    return null;
  }
  Future<bool> deleteEvent(String eventId, String token) async {
    final url = Uri.parse('https://www.googleapis.com/calendar/v3/calendars/primary/events/$eventId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        print('Event deleted successfully!');
        return true;
      } else {
        print('Google Calendar API Error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Network error deleting event: $e');
      return false;
    }
  }
}
