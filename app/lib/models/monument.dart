class Monument {
  final String id;
  final String name;
  final String location;
  final double latitude;
  final double longitude;
  final String era;
  final List<String> categories; // ['history', 'architecture']
  final String basicInfo;
  final String whyBuilt;
  final String culturalSignificance;
  final String symbolism;
  final String modernRelevance;
  final List<String> imageUrls;
  final String crowdLevel; // 'high', 'medium', 'low'
  final List<String> vibes; // ['peaceful', 'scenic']
  final double rating;

  Monument({
    required this.id,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.era,
    required this.categories,
    required this.basicInfo,
    required this.whyBuilt,
    required this.culturalSignificance,
    required this.symbolism,
    required this.modernRelevance,
    required this.imageUrls,
    required this.crowdLevel,
    required this.vibes,
    this.rating = 0.0,
  });

  factory Monument.fromFirestore(Map<String, dynamic> data, String id) {
    return Monument(
      id: id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      era: data['era'] ?? '',
      categories: List<String>.from(data['categories'] ?? []),
      basicInfo: data['basic_info'] ?? '',
      whyBuilt: data['why_built'] ?? '',
      culturalSignificance: data['cultural_significance'] ?? '',
      symbolism: data['symbolism'] ?? '',
      modernRelevance: data['modern_relevance'] ?? '',
      imageUrls: List<String>.from(data['image_urls'] ?? []),
      crowdLevel: data['crowd_level'] ?? 'medium',
      vibes: List<String>.from(data['vibes'] ?? []),
      rating: (data['rating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'era': era,
      'categories': categories,
      'basic_info': basicInfo,
      'why_built': whyBuilt,
      'cultural_significance': culturalSignificance,
      'symbolism': symbolism,
      'modern_relevance': modernRelevance,
      'image_urls': imageUrls,
      'crowd_level': crowdLevel,
      'vibes': vibes,
      'rating': rating,
    };
  }
}