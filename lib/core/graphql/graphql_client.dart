import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/core/constants/api_constants.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

ValueNotifier<GraphQLClient> buildGraphqlClientNotifier() {
  final HttpLink httpLink = HttpLink(ApiConstants.countriesGraphqlEndpoint);

  return ValueNotifier<GraphQLClient>(
    GraphQLClient(link: httpLink, cache: GraphQLCache()),
  );
}
