class LoginResponse {
  final String token;
  final int userId;
  final String nom;
  final String role;
  final bool emailVerifie;
  final bool telephoneVerifie;

  LoginResponse({
    required this.token,
    required this.userId,
    required this.nom,
    required this.role,
    required this.emailVerifie,
    required this.telephoneVerifie,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      userId: json['userId'] as int,
      nom: json['nom'] as String,
      role: json['role'] as String,
      emailVerifie: json['emailVerifie'] as bool,
      telephoneVerifie: json['telephoneVerifie'] as bool,
    );
  }

  



}
