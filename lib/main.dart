import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/home/presentation/home_shell_page.dart';
import 'package:flutter_application_1/core/graphql/graphql_client.dart';
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
          scaffoldBackgroundColor: const Color.fromARGB(255, 238, 255, 191),
          colorSchemeSeed: const Color.fromARGB(255, 27, 106, 175),
        ),
        home: const HomeShellPage(),
      ),
    );
  }
}
