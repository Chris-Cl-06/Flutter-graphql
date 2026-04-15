const String updateTaskMutation = r'''
  mutation UpdateTask(
    $id: ID!,
    $input: TaskUpdateInput!
  ) {
    updateTask(id: $id, input: $input) {
      id
      title
      description
      completed
      categoryId
    }
  }
''';

const String createTaskMutation = r'''
  mutation CreateTask($input: TaskInput!) {
    createTask(input: $input) {
      id
      title
      description
      completed
      categoryId
    }
  }
''';

const String deleteTaskMutation = r'''
  mutation toggleDeleteTask($id: ID!) {
    toggleDeleteTask(id: $id) {
      id
      deleted
    }
  }
''';
