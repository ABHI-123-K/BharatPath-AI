import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/interest_selection_screen.dart';
import 'services/firebase_service.dart';
import 'package:bharatpath_ai2/services/openai_service.dart';

import 'services/vision_service.dart';
import 'services/location_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const BharatPathApp());
}

class BharatPathApp extends StatelessWidget {
  const BharatPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => FirebaseService()),
        Provider(create: (_) => OpenAIService()),
        Provider(create: (_) => VisionService()),
        Provider(create: (_) => LocationService()),
      ],
      child: MaterialApp(
        title: 'BharatPath AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          scaffoldBackgroundColor: const Color(0xFFFFF8F0),
          textTheme: GoogleFonts.poppinsTextTheme(),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFFFF6F00),
            elevation: 0,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        home: const InterestSelectionScreen(),
      ),
    );
  }
}