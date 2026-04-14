const String getCategoriesQuery = r'''
  query GetCategories($offset: Int, $limit: Int) {
    categories(offset: $offset, limit: $limit) {
      items {
        id
        name
        isActive
      }
      pageInfo {
        offset
        limit
        totalCount
        hasNextPage
        hasPreviousPage
      }
    }
  }
''';
