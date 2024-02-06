import 'dart:io';
import 'dart:convert';
import 'package:flivekit/const.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Api {
  static final Api api = Api._internal();

  factory Api() {
    return api;
  }

  Api._internal();

  // LiveKit
  Future<String?> apiPostGetToken(String username, int userid) async {
    debugPrint('\n\nrestPostDyteMeeting');

    final response = await http.post(Uri.parse('$kFlkUrl/livekit/get-participant-token'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: jsonEncode({
          'room': 'livekit-123-standup',
          'username': username,
          'user_id': userid
        }));

    if (response.statusCode == 200) {
      Map jsonResp = json.decode(response.body);
      String? token = jsonResp['token'];

      return token;
    } else {
      debugPrint('Error restPostGetToken: ${response.reasonPhrase}');
      return null;
    }
  }
}
