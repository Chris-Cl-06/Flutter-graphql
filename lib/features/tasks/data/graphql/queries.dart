const String getTasksQuery = r'''
  query GetTasks($offset: Int, $limit: Int) {
    findAllTasks(deleted: false, offset: $offset, limit: $limit) {
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
