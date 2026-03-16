class AuthResponse{
  final String token;
  final String username;
  final String email;

  AuthResponse({
    required this.token,
    required this.username,
    required this.email,
  });

  factory AuthResponse.fromJson(Map<String, dynamica> json) {
    return AuthResponse(
      token: json['token' as String],
      username: json['username' as String],
      email: json['email' as String],
    );
  }
}