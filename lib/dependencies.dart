import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QoteVars {
  static const Color mainRed = Color(0xFFCC2323);
  static const Color mainPurple = Color(0xFFD244F2);
  static String serverAddress = 'localhost:20000';
  static int token = 0;
  static Map<String, dynamic> currentUser = {};
  static int currentNote = -1;
  static String latestResult = '';
}

class QoteAPI {
  static Map<String, String> authHeader = {
    'auth':
        '{"username": "${QoteVars.currentUser['username']}", "token": "${QoteVars.token}"}',
  };

  static Future<bool> signup(String firstName, String lastName,
      String emailAddress, String username, String password) async {
    var response = await http.post(
      Uri.http(QoteVars.serverAddress, 'account', {'action': 'signup'}),
      body: jsonEncode(
        <String, String>{
          'first_name': firstName,
          'last_name': lastName,
          'email_address': emailAddress,
          'username': username,
          'password': password
        },
      ),
    );
    if (response.body == 'success') {
      return true;
    } else {
      QoteVars.latestResult = response.body;
      return false;
    }
  }

  static Future<bool> login(String username, String password) async {
    var response = await http.post(
      Uri.http(QoteVars.serverAddress, 'account', {'action': 'login'}),
      body: jsonEncode(
          <String, String>{'username': username, 'password': password}),
    );
    if (response.body != 'false') {
      QoteVars.token = jsonDecode(response.body)['token'];
      QoteVars.currentUser = {
        'username': jsonDecode(response.body)['username']
      };
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> logout() async {
    var response = await http.post(
      Uri.http(QoteVars.serverAddress, 'account', {'action': 'logout'}),
      body: jsonEncode(
          <String, String>{'username': QoteVars.currentUser['username']}),
    );
    if (response.statusCode == 200) {
      QoteVars.token = 0;
      QoteVars.currentUser = {};
      return true;
    } else {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getAccount() async {
    var response = await http.get(
      Uri.http(QoteVars.serverAddress, 'account'),
      headers: {
        'auth':
            '{"username": "${QoteVars.currentUser['username']}", "token": "${QoteVars.token}"}',
      },
    );
    return jsonDecode(response.body);
  }

  static Future<bool> newNote() async {
    await http.post(
      Uri.http(QoteVars.serverAddress, 'qote'),
      headers: {
        'auth':
            '{"username": "${QoteVars.currentUser['username']}", "token": "${QoteVars.token}"}',
      },
    );
    return true;
  }

  static void editNote(String title, String body, int noteID) async {
    await http.put(
      Uri.http(QoteVars.serverAddress, 'qote', {'val': noteID.toString()}),
      headers: authHeader,
      body: jsonEncode(<String, String>{
        'title': title,
        'body': body,
      }),
    );
  }

  static Future<Map<String, dynamic>> getNotes({int noteID = -1}) async {
    var response = await http.get(
      Uri.http(QoteVars.serverAddress, 'qote'),
      headers: {
        'auth':
            '{"username": "${QoteVars.currentUser['username']}", "token": "${QoteVars.token}"}',
      },
    );
    if (noteID != -1) {
      return jsonDecode(response.body)[noteID.toString()];
    }
    return jsonDecode(response.body);
  }

  static void deleteNote(int noteID) async {
    await http.delete(
      Uri.http(QoteVars.serverAddress, 'qote', {'val': noteID.toString()}),
      headers: authHeader,
    );
  }

  static void colorNote(int noteID, String colorID) async {
    await http.put(
      Uri.http(
          QoteVars.serverAddress, 'qote/config', {'val': noteID.toString()}),
      headers: authHeader,
      body: jsonEncode(<String, String>{
        'color': colorID.toString(),
      }),
    );
  }
}

class QoteLocal {
  static Future<String> readSharedPrefs(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key).toString();
  }

  static void writeSharedPrefs(key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  static Future<bool> checkSharedPref(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }
}
