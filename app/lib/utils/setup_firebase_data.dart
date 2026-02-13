import '../services/firebase_service.dart';
import '../models/monument.dart';

class FirebaseDataSetup {
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> setupInitialData() async {
    final monuments = [
      Monument(
        id: 'taj_mahal',
        name: 'Taj Mahal',
        location: 'Agra, Uttar Pradesh',
        latitude: 27.1751,
        longitude: 78.0421,
        era: 'Mughal Era (1632-1653)',
        categories: ['history', 'architecture', 'spirituality'],
        basicInfo:
            'An ivory-white marble mausoleum on the right bank of the river Yamuna.',
        whyBuilt:
            'Built by Mughal emperor Shah Jahan in memory of his beloved wife Mumtaz Mahal.',
        culturalSignificance:
            'Symbol of eternal love and one of the finest examples of Mughal architecture.',
        symbolism:
            'Represents purity, symmetry, and the intersection of Islamic and Indian architectural styles.',
        modernRelevance:
            'UNESCO World Heritage Site and one of the New Seven Wonders of the World.',
        imageUrls: [
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bd/Taj_Mahal%2C_Agra%2C_India_edit3.jpg/1200px-Taj_Mahal%2C_Agra%2C_India_edit3.jpg'
        ],
        crowdLevel: 'high',
        vibes: ['peaceful', 'romantic', 'majestic'],
        rating: 4.8,
      ),
      Monument(
        id: 'red_fort',
        name: 'Red Fort',
        location: 'Delhi',
        latitude: 28.6562,
        longitude: 77.2410,
        era: 'Mughal Era (1639-1648)',
        categories: ['history', 'architecture', 'freedom movement'],
        basicInfo:
            'Historic fort served as the main residence of Mughal emperors for nearly 200 years.',
        whyBuilt:
            'Built by Shah Jahan as the palace fort of his new capital Shahjahanabad.',
        culturalSignificance:
            'Symbol of India\'s struggle for independence, where the Prime Minister hoists the national flag on Independence Day.',
        symbolism:
            'Represents the power and grandeur of the Mughal Empire and Indian sovereignty.',
        modernRelevance:
            'UNESCO World Heritage Site and a national symbol of India\'s independence.',
        imageUrls: [
          'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/Red_Fort_in_Delhi_03-2016_img3.jpg/1200px-Red_Fort_in_Delhi_03-2016_img3.jpg'
        ],
        crowdLevel: 'high',
        vibes: ['historic', 'grand', 'patriotic'],
        rating: 4.6,
      ),
      Monument(
        id: 'golden_temple',
        name: 'Golden Temple',
        location: 'Amritsar, Punjab',
        latitude: 31.6200,
        longitude: 74.8765,
        era: '16th Century',
        categories: ['spirituality', 'architecture', 'peace'],
        basicInfo:
            'The holiest Gurdwara of Sikhism, known for its golden dome and sacred pool.',
        whyBuilt:
            'Built by Guru Arjan Dev as a place of worship for all religions.',
        culturalSignificance:
            'Embodies Sikh values of equality, service, and community.',
        symbolism:
            'Gold represents spiritual enlightenment, the four entrances symbolize openness to all.',
        modernRelevance:
            'Serves free meals to 100,000+ people daily, exemplifying selfless service.',
        imageUrls: [
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Golden_Temple%2C_Amritsar%2C_India.jpg/1200px-Golden_Temple%2C_Amritsar%2C_India.jpg'
        ],
        crowdLevel: 'medium',
        vibes: ['peaceful', 'spiritual', 'serene'],
        rating: 4.9,
      ),
      Monument(
        id: 'qutub_minar',
        name: 'Qutub Minar',
        location: 'Delhi',
        latitude: 28.5244,
        longitude: 77.1855,
        era: '12th Century',
        categories: ['history', 'architecture'],
        basicInfo:
            'A 73-meter tall red sandstone tower, tallest brick minaret in the world.',
        whyBuilt:
            'Built by Qutb-ud-din Aibak to celebrate Muslim dominance in Delhi.',
        culturalSignificance:
            'Represents the beginning of Muslim rule in India.',
        symbolism:
            'Tower of victory and the fusion of Islamic and Indian architectural styles.',
        modernRelevance: 'UNESCO World Heritage Site.',
        imageUrls: [
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/50/Qutub_Minar_in_the_monsoons.jpg/1200px-Qutub_Minar_in_the_monsoons.jpg'
        ],
        crowdLevel: 'medium',
        vibes: ['historic', 'ancient'],
        rating: 4.5,
      ),
      Monument(
        id: 'hampi',
        name: 'Hampi',
        location: 'Karnataka',
        latitude: 15.3350,
        longitude: 76.4600,
        era: 'Vijayanagara Empire (14th-16th Century)',
        categories: ['history', 'architecture', 'nature'],
        basicInfo:
            'Ancient village with ruins of the Vijayanagara Empire, spread over 4,100 hectares.',
        whyBuilt:
            'Capital city of the Vijayanagara Empire, one of the richest cities of its time.',
        culturalSignificance:
            'Represents the zenith of South Indian architecture and culture.',
        symbolism:
            'Blend of Hindu mythology, art, and engineering prowess.',
        modernRelevance:
            'UNESCO World Heritage Site, popular among history enthusiasts and backpackers.',
        imageUrls: [
          'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Virupaksha_Temple_Hampi.jpg/1200px-Virupaksha_Temple_Hampi.jpg'
        ],
        crowdLevel: 'low',
        vibes: ['scenic', 'peaceful', 'adventurous'],
        rating: 4.7,
      ),
    ];

    for (var monument in monuments) {
      await _firebaseService.addMonument(monument);
      print('Added: ${monument.name}');
    }

    print('✅ Firebase data setup complete!');
  }
}