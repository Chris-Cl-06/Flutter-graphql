const String createCategoryMutation = r'''
  mutation CreateCategory($input: CategoryInput!) {
    createCategory(input: $input) {
      id
      name
      isActive
    }
  }
''';

const String deleteCategoryMutation = r'''
  mutation ToggleDeleteCategory($id: ID!) {
    toggleDeleteCategory(id: $id) {
        id
        name
        isActive
    }
  }
''';

const String updateCategoryMutation = r'''
  mutation UpdateCategory($id: ID!, $name: String, $isActive: Boolean) {
    updateCategory(id: $id, input: { name: $name, isActive: $isActive }) {
        id
        name
        isActive
    }
}
''';
