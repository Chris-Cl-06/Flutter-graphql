const String createCategoryMutation = r'''
  mutation CreateCategory($input: CategoryInput!) {
    createCategory(input: $input) {
      id
      name
      isActive
    }
  }
''';
