const String createCategoryMutation = r'''
  mutation CreateCategory($input: CategoryInput!) {
    createCategory(input: $input) {
      id
      name
      isActive
    }
  }
''';

//es provisional , seteamos el estado a no activo para simular un borrado hasta que este implementado
const String deleteCategoryMutation = r'''
  mutation UpdateCategory($id: ID!, $isActive: Boolean!) {
    updateCategory(id: $id, input: { isActive: $isActive }) {
        id
        isActive
    }
  }
''';
