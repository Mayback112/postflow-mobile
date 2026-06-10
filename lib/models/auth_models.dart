enum AuthProvider {
  google('GOOGLE'),
  apple('APPLE');

  const AuthProvider(this.apiValue);

  final String apiValue;
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.name,
    this.profileImageUrl,
  });

  final String id;
  final String email;
  final String? name;
  final String? profileImageUrl;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
    };
  }
}

class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, String> toStorage() {
    return {'accessToken': accessToken, 'refreshToken': refreshToken};
  }
}

class AuthSession {
  const AuthSession({required this.user, required this.tokens});

  final AuthUser user;
  final AuthTokens tokens;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      tokens: AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>),
    );
  }
}

class SignRequest {
  const SignRequest({
    required this.provider,
    required this.idToken,
    this.name,
    this.profileImageUrl,
  });

  final AuthProvider provider;
  final String idToken;
  final String? name;
  final String? profileImageUrl;

  Map<String, dynamic> toJson() {
    return {
      'provider': provider.apiValue,
      'idToken': idToken,
      if (name != null && name!.isNotEmpty) 'name': name,
      if (profileImageUrl != null && profileImageUrl!.isNotEmpty)
        'profileImageUrl': profileImageUrl,
    };
  }
}
