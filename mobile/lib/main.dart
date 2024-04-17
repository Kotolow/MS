import 'package:flutter/material.dart';
import 'package:mobile/screens/home_screen.dart';
import 'package:mobile/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/registration_provider.dart';
import 'package:mobile/providers/manga_provider.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  await authProvider.getStoredToken();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => MangaProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return MaterialApp(
      title: 'Manga Sense',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          titleTextStyle: GoogleFonts.merriweather(
            textStyle: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.merriweather(
            textStyle: TextStyle(color: Colors.white, fontSize: 18),
          ),
          bodyMedium: GoogleFonts.merriweather(
            textStyle: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
        cardColor: Colors.grey[850],
      ),
      home: authProvider.isAuthenticated ? HomeScreen(currentIndex: 0) : LoginScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(currentIndex: 0),
      },
    );
  }
}
