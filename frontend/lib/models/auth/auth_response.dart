class AuthResponse {
  final String token;
  final String username;
  final String role;

  AuthResponse({
    required this.token,
    required this.username,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token:    json['token']    as String? ?? '',
        username: json['username'] as String? ?? '',
        role:     json['role']     as String? ?? 'USER',
      );
}