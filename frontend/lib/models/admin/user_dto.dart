class UserDto {
  final int id;
  final String username;
  final bool active;
  final String role;
  final String? createdAt;
  final String? lastLogin;
  final int characterCount;

  const UserDto({
    required this.id,
    required this.username,
    required this.active,
    required this.role,
    this.createdAt,
    this.lastLogin,
    required this.characterCount,
  });

  factory UserDto.fromJson(Map<String, dynamic> j) => UserDto(
        id:             (j['id'] as num).toInt(),
        username:       j['username'] as String? ?? '',
        active:         j['active'] as bool? ?? true,
        role:           (j['role'] as String?)?.toString() ?? 'USER',
        createdAt:      j['createdAt'] as String?,
        lastLogin:      j['lastLogin'] as String?,
        characterCount: (j['characterCount'] as num?)?.toInt() ?? 0,
      );

      bool get isAdmin => role == 'ADMIN';
}