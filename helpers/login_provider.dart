import 'package:googleapis/drive/v3.dart' as drive_api;
enum LoginProvider { google }

extension LoginProviderExtension on LoginProvider {
  String get key {
    switch (this) {
      case LoginProvider.google:
        return 'google';
    }
  }

  String get authorizationEndpoint {
    switch (this) {
      case LoginProvider.google:
        return "https://accounts.google.com/o/oauth2/v2/auth";
    }
  }

  String get tokenEndpoint {
    switch (this) {
      case LoginProvider.google:
        return "https://oauth2.googleapis.com/token";
    }
  }

  String get clientId {
    switch (this) {
      case LoginProvider.google:
        return "252130809125-1a3h4ddiol2bm2d0vts850f7ua9skqk5.apps.googleusercontent.com";
    }
  }

  String? get clientSecret {
    switch (this) {
      case LoginProvider.google:
        return "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";
    }
  }

  List<String> get scopes {
    return <String>['email', drive_api.DriveApi.driveScope];// OAuth Scopes
  }
}