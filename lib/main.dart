import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/graphql/graphql_client.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Declaramos la variable del cliente
  late ValueNotifier<GraphQLClient> client;

  @override
  void initState() {
    super.initState();
    // Inicializamos el cliente una sola vez al iniciar la app
    client = buildGraphqlClientNotifier();
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF1E88E5),
        ),
        home: const HomePage(),
      ),
    );
  }
}
