import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CountriesPage extends StatefulWidget {
  final String continentCode;
  final String continentName;

  const CountriesPage({
    super.key,
    required this.continentCode,
    required this.continentName,
  });

  @override
  State<CountriesPage> createState() => _CountriesPageState();
}

class _CountriesPageState extends State<CountriesPage> {
  // 1. Necesitamos un ScrollController para detectar el final de la lista
  final ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paises de ${widget.continentName}'),
        centerTitle: true,
      ),
      body: Query(
        options: QueryOptions(
          document: gql(r'''
            query GetCountriesByContinent($code: ID!, $offset: Int, $limit: Int) {
              continent(code: $code) {
                countries(offset: $offset, limit: $limit) { # Parámetros de paginación
                  code
                  name
                  emoji
                  capital
                  currency
                }
              }
            }
          '''),
          variables: {
            'code': widget.continentCode,
            'offset': 0, // Empezamos desde el inicio
            'limit': 20, // Cargamos de 20 en 20
          },
        ),
        builder: (result, {fetchMore, refetch}) {
          if (result.isLoading && result.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result.hasException) {
            return Center(child: Text('Error: ${result.exception}'));
          }

          final continent = result.data?['continent'];
          final List countries = (continent?['countries'] as List?) ?? [];

          //listener para saber cuando llegamos al final del scroll
          _scrollController.addListener(() {
            final threshold = _scrollController.position.maxScrollExtent - 200;
            if (_scrollController.position.pixels >= threshold &&
                !_isFetchingMore) {
              _loadMoreData(fetchMore, countries.length);
            }
          });

          return ListView.separated(
            controller: _scrollController, // Asignamos el controlador
            itemCount: countries.length + 1, // +1 para el cargando al final
            separatorBuilder: (_, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              // Si llegamos al último elemento, mostramos un loader
              if (index == countries.length) {
                return _isFetchingMore
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : const SizedBox.shrink();
              }

              final country = countries[index];
              return ListTile(
                leading: Text(
                  country['emoji'] ?? '🌍',
                  style: const TextStyle(fontSize: 22),
                ),
                title: Text('${country['name']} (${country['code']})'),
                subtitle: Text('Capital: ${country['capital'] ?? 'N/A'}'),
              );
            },
          );
        },
      ),
    );
  }

  // 3. Función lógica para pedir más datos
  void _loadMoreData(FetchMore? fetchMore, int currentCount) async {
    if (fetchMore == null) return;

    setState(() {
      _isFetchingMore = true;
    });

    fetchMore(
      FetchMoreOptions(
        variables: {
          'offset': currentCount,
        }, // Pedimos a partir de los que ya tenemos
        updateQuery: (previousResultData, fetchMoreResultData) {
          // Unimos las dos listas
          final List<dynamic> oldCountries =
              previousResultData!['continent']['countries'];
          final List<dynamic> newCountries =
              fetchMoreResultData!['continent']['countries'];

          // Si el API no devuelve más, retornamos lo anterior
          if (newCountries.isEmpty) return previousResultData;

          // Creamos un nuevo mapa de datos con la lista combinada
          return {
            'continent': {
              '__typename': 'Continent',
              'countries': [...oldCountries, ...newCountries],
            },
          };
        },
      ),
    ).whenComplete(() {
      if (mounted)
        setState(() {
          _isFetchingMore = false;
        });
    });
  }
}
