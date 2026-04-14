const String getCategoriesQuery = r'''
  query GetCategories {
    categories {
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
