
import 'dart:io';


import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:notebars/global.dart';
import 'package:notebars/helpers/desktop_login_manager.dart';
import 'package:notebars/helpers/login_provider.dart';
import 'package:notebars/helpers/secure_storage_service.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

class DesktopOAuthManager extends DesktopLoginManager {
final LoginProvider loginProvider;

DesktopOAuthManager({
required this.loginProvider,
}) : super();

Future<void> login() async {
  await redirectServer?.close();
  // Bind to an ephemeral port on localhost
  redirectServer = await HttpServer.bind('localhost', 0);
  final redirectURL = 'http://localhost:${redirectServer!.port}/auth';
  // final redirectURL = 'com.notebars.app:/';
  var authenticatedHttpClient =
  await _getOAuth2Client(Uri.parse(redirectURL));
  print("CREDENTIALS ${authenticatedHttpClient.credentials}");

  /// HANDLE SUCCESSFULL LOGIN RESPONSE HERE
  ///

  app.authHeaders = <String, String>{
    'Authorization': 'Bearer ${authenticatedHttpClient.credentials.accessToken}',
  // TODO(kevmoo): Use the correct value once it's available from authentication
  // See https://github.com/flutter/flutter/issues/80905
  'X-Goog-AuthUser': '0',
  };

  SecureStorageService.saveUser(authenticatedHttpClient.credentials);

  return;
}

Future<oauth2.Client> _getOAuth2Client(Uri redirectUrl) async {

  var grant = oauth2.AuthorizationCodeGrant(
    loginProvider.clientId,
    Uri.parse(loginProvider.authorizationEndpoint),
    Uri.parse(loginProvider.tokenEndpoint),
    httpClient: _JsonAcceptingHttpClient(),
    secret: loginProvider.clientSecret,
  );
  var authorizationUrl =
  grant.getAuthorizationUrl(Uri.parse('partyai'), scopes: loginProvider.scopes);

  // await redirect(authorizationUrl);

  final result = FlutterWebAuth.authenticate(url: authorizationUrl.toString(), callbackUrlScheme: 'partyai',);

  var responseQueryParameters = await listen();
  var client = await grant.handleAuthorizationResponse(responseQueryParameters);
  return client;
}
}

class _JsonAcceptingHttpClient extends http.BaseClient {
  final _httpClient = http.Client();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Accept'] = 'application/json';
    return _httpClient.send(request);
  }
}