const String getTasksQuery = r'''
  query GetTasks($offset: Int, $limit: Int) {
    findAllTasks(offset: $offset, limit: $limit) {
      items {
        id
        title
        description
        completed
        categoryId
        category {
          id
          name
        }
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
