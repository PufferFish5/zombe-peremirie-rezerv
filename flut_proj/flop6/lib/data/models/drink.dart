class Drink {
  final int id;
  final String name;
  final String series;
  final String flavorProfile;
  final String description;
  final String category;
  final double price;
  final String imagePath;

  const Drink({
    required this.id,
    required this.name,
    required this.series,
    required this.flavorProfile,
    required this.description,
    required this.category,
    required this.price,
    required this.imagePath,
  });

  factory Drink.fromMap(Map<String, dynamic> map) => Drink(
    id:            map['id']             as int,
    name:          map['name']           as String,
    series:        map['series']         as String,
    flavorProfile: map['flavor_profile'] as String,
    description:   map['description']    as String,
    category:      map['category']       as String,
    price:         (map['price'] as num).toDouble(),
    imagePath:     map['image_path']     as String? ?? '',
  );
}