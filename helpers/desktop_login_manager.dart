

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';
import 'package:window_to_front/window_to_front.dart';

class DesktopLoginManager {
  HttpServer? redirectServer;
  oauth2.Client? client;

  // Launch the URL in the browser using url_launcher
  Future<void> redirect(Uri authorizationUrl) async {
    var url = authorizationUrl.toString();
    if (true) {
      await launch(url);
    } else {
      throw Exception('Could not launch $url');
    }
  }


  Future<Map<String, String>> listen() async {
    var request = await redirectServer!.first;
    var params = request.uri.queryParameters;
    await WindowToFront
        .activate(); // Using window_to_front package to bring the window to the front after successful login.
    request.response.statusCode = 200;
    request.response.headers.set('content-type', 'text/plain');
    request.response.writeln('Authenticated! You can close this tab.');
    await request.response.close();
    await redirectServer!.close();
    redirectServer = null;
    return params;
  }
}