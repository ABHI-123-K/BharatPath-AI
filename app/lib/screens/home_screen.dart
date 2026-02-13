import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// ✅ Updated imports
import '../services/firebase_service.dart';
import '../services/openai_service.dart';
import '../services/location_service.dart';
import '../models/monument.dart';
import 'camera_screen.dart';
import 'search_screen.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<String> interests;
  final String userId;

  const HomeScreen({
    super.key,
    required this.interests,
    required this.userId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Monument> _recommendations = [];
  Map<String, String> _recommendationReasons = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
  final firebaseService = context.read<FirebaseService>();
  final openAIService = context.read<OpenAIService>();
  final locationService = context.read<LocationService>();

  setState(() => _isLoading = true);

  try {
    print('🔍 DEBUG: User interests: ${widget.interests}');
    
    // Get monuments based on user interests
    final monuments = await firebaseService.getMonumentsByCategories(widget.interests);
    
    print('🔍 DEBUG: Found ${monuments.length} monuments');
    for (var m in monuments) {
      print('   - ${m.name}: ${m.categories}');
    }

    if (monuments.isEmpty) {
      print('❌ No monuments found! Check Firebase data.');
      setState(() => _isLoading = false);
      return;
    }

    // Get user location for distance sorting
    final userLocation = await locationService.getCurrentLocation();
    print('🔍 DEBUG: User location: ${userLocation?.latitude}, ${userLocation?.longitude}');

    // Sort by distance if location available
    if (userLocation != null) {
      monuments.sort((a, b) {
        final distanceA = locationService.calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          a.latitude,
          a.longitude,
        );
        final distanceB = locationService.calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          b.latitude,
          b.longitude,
        );
        return distanceA.compareTo(distanceB);
      });
    }

    // Generate recommendation reasons using AI
    Map<String, String> reasons = {};
    for (var monument in monuments.take(5)) {
      print('🔍 DEBUG: Generating reason for ${monument.name}...');
      final reason = await openAIService.generateRecommendationReason(
        monumentName: monument.name,
        monumentCategories: monument.categories,
        userInterests: widget.interests,
      );
      reasons[monument.id] = reason;
      print('   ✅ Reason: $reason');
    }

    setState(() {
      _recommendations = monuments.take(5).toList();
      _recommendationReasons = reasons;
      _isLoading = false;
    });
    
    print('✅ DEBUG: Loaded ${_recommendations.length} recommendations');
  } catch (e) {
    print('❌ ERROR loading recommendations: $e');
    setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFFFF6F00),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'BharatPath AI',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SearchScreen(
                          userId: widget.userId,
                          userInterests: widget.interests,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scan Monument Button
                    _buildScanButton(),
                    const SizedBox(height: 30),

                    // Personalized For You Section
                    Text(
                      'Personalized For You',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Based on your interests: ${widget.interests.join(', ')}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Recommendations
                    _isLoading
                        ? _buildLoadingShimmer()
                        : _buildRecommendationsList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CameraScreen(
              userId: widget.userId,
              userInterests: widget.interests,
            ),
          ),
        );
      },
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6F00).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'CultureScan',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Point your camera at any monument',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Icon(
                Icons.camera_alt,
                size: 60,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsList() {
    if (_recommendations.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Icon(Icons.explore_off, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 20),
            Text(
              'No recommendations yet',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _recommendations.map((monument) {
        return _buildMonumentCard(monument);
      }).toList(),
    );
  }

  Widget _buildMonumentCard(Monument monument) {
    final reason = _recommendationReasons[monument.id] ?? 'Recommended for you';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              monument: monument,
              userId: widget.userId,
              userInterests: widget.interests,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: monument.imageUrls.isNotEmpty
                  ? Image.network(
                      monument.imageUrls.first,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 50),
                      ),
                    )
                  : Container(
                      height: 180,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 50),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    monument.name,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          monument.location,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // AI-generated reason
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            size: 18, color: Color(0xFFFF6F00)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reason,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFFFF6F00),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 280,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}