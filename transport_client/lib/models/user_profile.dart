class UserProfile {
  final int id;
  final String nom;
  final String? prenom;
  final String? email;
  final String telephone;
  final String role;
  final bool emailVerifie;
  final bool telephoneVerifie;

  UserProfile({
    required this.id,
    required this.nom,
    this.prenom,
    this.email,
    required this.telephone,
    required this.role,
    required this.emailVerifie,
    required this.telephoneVerifie,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String?,
      email: json['email'] as String?,
      telephone: json['telephone'] as String,
      role: json['role'] as String,
      emailVerifie: json['emailVerifie'] as bool? ?? false,
      telephoneVerifie: json['telephoneVerifie'] as bool? ?? false,
    );
  }
}