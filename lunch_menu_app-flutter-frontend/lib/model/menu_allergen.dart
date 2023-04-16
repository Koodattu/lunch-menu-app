import 'dart:convert';

class Allergen {
  Allergen({
    required this.id,
    required this.allergenSymbol,
  });

  final int id;
  final String allergenSymbol;

  factory Allergen.fromRawJson(String str) => Allergen.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Allergen.fromJson(Map<String, dynamic> json) => Allergen(
        id: json["id"],
        allergenSymbol: json["allergenSymbol"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "allergenSymbol": allergenSymbol,
      };
}
