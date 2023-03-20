

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oauth2/oauth2.dart';
import 'package:jwt_decode/jwt_decode.dart';


abstract class SecureStorageService {

  static FlutterSecureStorage? _secureStorageInstance;

  static FlutterSecureStorage get secureStorageInstance {
    return _secureStorageInstance ??= const FlutterSecureStorage();
  }

  static saveUser(Credentials credentials) async{

    Map<String, dynamic>? payload;
    if(credentials.idToken != null){
      payload = Jwt.parseJwt(credentials.idToken!);
    }
    Map<String, dynamic> user = {
      'access_token' : credentials.accessToken,
      'id_token' : credentials.idToken,
      'refresh_token' : credentials.refreshToken,
      'token_exp_date': credentials.expiration?.millisecondsSinceEpoch,
      'email': payload?["email"]
    };
    await secureStorageInstance.write(key: 'user', value: jsonEncode(user));
  }

  static Future<WindowsUser?> getUser() async {
    String? userString = await secureStorageInstance.read(key: 'user',);
    if(userString == null || userString.isEmpty) return null;
    return WindowsUser.fromMap(jsonDecode(userString));
  }

}

class WindowsUser {

  WindowsUser(this.accessToken, this.idToken, this.refreshToken, this.tokenExpDate, this.email);

  final String? accessToken;
  final String? idToken;
  final String? refreshToken;
  final int? tokenExpDate;
  final String? email;

  factory WindowsUser.fromMap(Map<String, dynamic> map) => WindowsUser(
    map['access_token'],
    map['id_token'],
    map['refresh_token'],
    map['token_exp_date'],
    map['email'],
  );


}