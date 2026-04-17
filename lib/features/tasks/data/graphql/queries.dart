const String getTasksQuery = r'''
  query GetTasks($offset: Int, $limit: Int , $categoryId: [ID!]) {
    findAllTasks(deleted: false, offset: $offset, limit: $limit, categoryIds: $categoryId) {
      items {
        id
        title
        description
        completed
        categoryId
        category {
          id
          name
          isActive
        }
      }
      pageInfo {
        offset
        limit
        totalCount
        hasNextPage
        hasPreviousPage
        taskCompleted
      }
    }
  }
''';
