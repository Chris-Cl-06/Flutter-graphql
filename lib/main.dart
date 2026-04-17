import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auth/presentation/login.dart';
import 'package:flutter_application_1/features/home/presentation/home_shell_page.dart';
import 'package:flutter_application_1/core/graphql/graphql_client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ValueNotifier<GraphQLClient> client;

  @override
  void initState() {
    super.initState();
    client = buildGraphqlClientNotifier();
  }

  @override
  Widget build(BuildContext context) {
    // Updated palette: slightly richer teal primary and softer backgrounds
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF04635E),
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF04635E), // deeper teal
          secondary: const Color(0xFFF59E0B), // amber accent (unchanged)
          surface: const Color(0xFFFFFFFF),
          background: const Color(0xFFF5F9FF),
          outline: const Color(0xFF9FB3C8),
          outlineVariant: const Color(0xFFE6EEF6),
        );

    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeShellPage(),
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          scaffoldBackgroundColor: const Color(0xFFF5F9FF),
          textTheme: GoogleFonts.manropeTextTheme(),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.white.withOpacity(0.92),
            indicatorColor: colorScheme.primary.withOpacity(0.14),
            elevation: 0,
            height: 68,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? colorScheme.primary : colorScheme.outline,
              );
            }),
          ),
        ),
        //home: const HomeShellPage(),
        // home: const LoginScreen(),
      ),
    );
  }
}
