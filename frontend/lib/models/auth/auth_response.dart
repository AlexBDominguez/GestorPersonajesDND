class AuthResponse {
  final String token;
  final String refreshToken;
  final String username;
  final String role;

  AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.username,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token:        json['token']        as String? ?? '',
        refreshToken: json['refreshToken'] as String? ?? '',
        username:     json['username']     as String? ?? '',
        role:         json['role']         as String? ?? 'USER',
      );
}