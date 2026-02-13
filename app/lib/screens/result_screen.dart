import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// ✅ Updated imports
import '../models/monument.dart';
import '../services/openai_service.dart';
import 'reflection_screen.dart';

class ResultScreen extends StatefulWidget {
  final Monument monument;
  final String userId;
  final List<String> userInterests;

  const ResultScreen({
    super.key,
    required this.monument,
    required this.userId,
    required this.userInterests,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String? _personalizedExplanation;
  bool _isLoadingExplanation = true;

  @override
  void initState() {
    super.initState();
    _loadPersonalizedExplanation();
  }

  Future<void> _loadPersonalizedExplanation() async {
    final openAIService = context.read<OpenAIService>();

    try {
      final explanation =
          await openAIService.generatePersonalizedExplanation(
        monumentName: widget.monument.name,
        basicInfo: widget.monument.basicInfo,
        userInterests: widget.userInterests,
      );

      setState(() {
        _personalizedExplanation = explanation;
        _isLoadingExplanation = false;
      });
    } catch (e) {
      setState(() {
        _personalizedExplanation =
            'Unable to generate personalized explanation.';
        _isLoadingExplanation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: CustomScrollView(
        slivers: [
          // Image Header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFFFF6F00),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.monument.name,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    const Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              background: widget.monument.imageUrls.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.monument.imageUrls.first,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(color: Colors.grey[300]),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location & Era
                  _buildQuickInfo(),
                  const SizedBox(height: 25),

                  // Personalized AI Explanation
                  _buildPersonalizedSection(),
                  const SizedBox(height: 25),

                  // Cultural Details
                  _buildInfoBox('📍 Location', widget.monument.location),
                  _buildInfoBox('🏛 Era', widget.monument.era),
                  _buildInfoBox('ℹ️ Basic Info', widget.monument.basicInfo),
                  _buildInfoBox('🏗 Why Built', widget.monument.whyBuilt),
                  _buildInfoBox('🎭 Cultural Significance',
                      widget.monument.culturalSignificance),
                  _buildInfoBox('🔱 Symbolism', widget.monument.symbolism),
                  _buildInfoBox('🌍 Modern Relevance',
                      widget.monument.modernRelevance),

                  const SizedBox(height: 30),

                  // Reflection Button
                  _buildReflectionButton(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFFFF6F00)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.monument.location,
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6F00),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.white, size: 18),
              const SizedBox(width: 5),
              Text(
                widget.monument.rating.toString(),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalizedSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFFFF6F00)),
              const SizedBox(width: 10),
              Text(
                'Why You\'ll Love This',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF6F00),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _isLoadingExplanation
              ? const Center(child: CircularProgressIndicator())
              : Text(
                  _personalizedExplanation ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.grey[800],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFF6F00),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReflectionScreen(
                monument: widget.monument,
                userId: widget.userId,
              ),
            ),
          );
        },
        icon: const Icon(Icons.edit_note, color: Colors.white),
        label: Text(
          'Share Your Reflection',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6F00),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
        ),
      ),
    );
  }
}