import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/continents_card.dart';
import 'package:flutter_application_1/pages/second_page.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Continentes'), centerTitle: true),
      // 1. El widget Query es el "motor" que busca los datos.
      body: Query(
        options: QueryOptions(
          document: gql(r'''
            query GetContinents {
              continents {
                code
                name
                countries {
                  code
                }
              }
            }
          '''), // Aquí definimos la consulta exacta que queremos enviar.
        ),
        // 2. El builder se encarga de REACCIONAR a lo que pasa con la petición.
        // Recibe 'result' (estado de la data) y las funciones de control {fetchMore, refetch}.
        builder: (result, {fetchMore, refetch}) {
          // A) ESTADO: CARGANDO
          // Mientras la petición está en viaje, mostramos un spinner.
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // B) ESTADO: ERROR
          // Si el servidor falla o no hay internet, mostramos el error.
          if (result.hasException) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No se pudieron cargar continentes.\n${result.exception}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // C) PROCESAMIENTO DE DATOS
          // Si llegamos aquí, la data llegó. Extraemos la lista de continentes.
          // Usamos ?? [] para evitar errores si la data viene nula.
          final continents = (result.data?['continents'] as List?) ?? [];

          // Si la lista está vacía, avisamos al usuario.
          if (continents.isEmpty) {
            return const Center(child: Text('Sin datos'));
          }

          // D) ESTADO: ÉXITO (Dibuja la lista)
          return ListView.builder(
            itemCount: continents.length,
            itemBuilder: (context, index) {
              // Extraemos cada continente individual como un Mapa de datos.
              final continent = continents[index] as Map<String, dynamic>;
              final countries = (continent['countries'] as List?) ?? [];

              return ContinentCard(
                name: continent['name'] as String,
                code: continent['code'] as String,
                count: countries.length, // Calculamos cuántos países tiene.
                onTap: () {
                  // Navegación a la segunda página pasando los datos obtenidos.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CountriesPage(
                        continentCode: continent['code'] as String,
                        continentName: continent['name'] as String,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
