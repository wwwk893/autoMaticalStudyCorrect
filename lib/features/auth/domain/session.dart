class UserSession {
  const UserSession({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    this.expiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
  final DateTime? expiresAt;

  bool get isExpired {
    final expiry = expiresAt;
    if (expiry == null) {
      return false;
    }
    return DateTime.now().isAfter(expiry);
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'userId': userId,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      userId: json['userId'] as String,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
    );
  }
}
