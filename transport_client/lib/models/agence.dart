class Agence {
  final int id;
  final String nom;

  Agence({required this.id, required this.nom});

  factory Agence.fromJson(Map<String, dynamic> json) {
    return Agence(
      id: json['id'] as int, 
      nom: json['nom'] as String? ?? ''
      );
  }
}
