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
  mutation DeleteTask($id: ID!) {
    deleteTask(id: $id)
  }
''';
