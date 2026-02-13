import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/openai_service.dart';
import '../services/firebase_service.dart';
import '../models/monument.dart';
import 'result_screen.dart';

class SearchScreen extends StatefulWidget {
  final String userId;
  final List<String> userInterests;

  const SearchScreen({
    super.key,
    required this.userId,
    required this.userInterests,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Monument> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchQuery = _searchController.text.trim();
    });

    final openAIService = context.read<OpenAIService>();
    final firebaseService = context.read<FirebaseService>();

    try {
      // Parse search intent using AI
      final searchIntent =
          await openAIService.parseSearchIntent(_searchController.text);

      print('Search Intent: $searchIntent');

      // Get all monuments
      List<Monument> allMonuments = await firebaseService.getAllMonuments();

      // Filter based on extracted categories
      if (searchIntent['categories'] != null) {
        final categories = List<String>.from(searchIntent['categories']);
        allMonuments = allMonuments.where((monument) {
          return monument.categories
              .any((cat) => categories.contains(cat.toLowerCase()));
        }).toList();
      }

      // Filter by vibes
      if (searchIntent['vibes'] != null) {
        final vibes = List<String>.from(searchIntent['vibes']);
        allMonuments = allMonuments.where((monument) {
          return monument.vibes
              .any((vibe) => vibes.contains(vibe.toLowerCase()));
        }).toList();
      }

      // Filter by crowd preference
      if (searchIntent['crowdPreference'] != null) {
        final crowdPref = searchIntent['crowdPreference'].toString().toLowerCase();
        allMonuments = allMonuments
            .where((monument) => monument.crowdLevel == crowdPref)
            .toList();
      }

      setState(() {
        _searchResults = allMonuments;
        _isSearching = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text('Smart Search', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFFF6F00),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  style: GoogleFonts.poppins(),
                  decoration: InputDecoration(
                    hintText: 'e.g., "peaceful places with nature"',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFFF6F00)),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _performSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6F00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'Search',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6F00)),
                    ),
                  )
                : _searchResults.isEmpty
                    ? _buildEmptyState()
                    : _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            _searchQuery.isEmpty
                ? 'Try searching for monuments'
                : 'No results found for "$_searchQuery"',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Try: "peaceful temples" or "forts near Delhi"',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final monument = _searchResults[index];
        return _buildResultCard(monument);
      },
    );
  }

  Widget _buildResultCard(Monument monument) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              monument: monument,
              userId: widget.userId,
              userInterests: widget.userInterests,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: monument.imageUrls.isNotEmpty
                  ? Image.network(
                      monument.imageUrls.first,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image),
                    ),
            ),
            const SizedBox(width: 15),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monument.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    monument.location,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 5,
                    children: monument.vibes.take(2).map((vibe) {
                      return Chip(
                        label: Text(
                          vibe,
                          style: GoogleFonts.poppins(fontSize: 11),
                        ),
                        backgroundColor: const Color(0xFFFFF3E0),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}