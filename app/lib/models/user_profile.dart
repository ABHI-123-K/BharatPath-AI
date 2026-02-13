class UserProfile {
  final String userId;
  final List<String> interests;
  final List<String> visitedMonuments;
  final Map<String, Reflection> reflections;

  UserProfile({
    required this.userId,
    required this.interests,
    this.visitedMonuments = const [],
    this.reflections = const {},
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data, String id) {
    Map<String, Reflection> reflectionsMap = {};
    if (data['reflections'] != null) {
      (data['reflections'] as Map<String, dynamic>).forEach((key, value) {
        reflectionsMap[key] = Reflection.fromMap(value);
      });
    }

    return UserProfile(
      userId: id,
      interests: List<String>.from(data['interests'] ?? []),
      visitedMonuments: List<String>.from(data['visited_monuments'] ?? []),
      reflections: reflectionsMap,
    );
  }

  Map<String, dynamic> toFirestore() {
    Map<String, dynamic> reflectionsMap = {};
    reflections.forEach((key, value) {
      reflectionsMap[key] = value.toMap();
    });

    return {
      'interests': interests,
      'visited_monuments': visitedMonuments,
      'reflections': reflectionsMap,
    };
  }
}

class Reflection {
  final String note;
  final int rating;
  final DateTime timestamp;

  Reflection({
    required this.note,
    required this.rating,
    required this.timestamp,
  });

  factory Reflection.fromMap(Map<String, dynamic> data) {
    return Reflection(
      note: data['note'] ?? '',
      rating: data['rating'] ?? 0,
      timestamp: DateTime.parse(data['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'note': note,
      'rating': rating,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}