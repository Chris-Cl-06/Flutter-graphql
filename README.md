# Task & Category Manager (Flutter + GraphQL)

App Flutter con dos modulos principales:

- Tareas
- Categorias

Todo el consumo de datos se hace por GraphQL con graphql_flutter.

## Stack

- Flutter (Material 3)
- graphql_flutter
- google_fonts

## Que hace la app

### Tareas

- Lista paginada de tareas
- Crear tarea
- Editar tarea (pantalla dedicada)
- Toggle de completada/incompleta
- Borrado logico
- Dialog de informacion de pagina
- Easter egg: tocar el titulo Tareas 6 veces seguidas muestra un GIF por 3 segundos

### Categorias

- Lista paginada de categorias
- Crear categoria
- Toggle de activa/inactiva
- Editar nombre inline (lapiz -> check)
- Borrado logico
- Dialog de informacion de pagina

## Estructura del proyecto

Ruta base: lib

- core
	- constants
		- api_constants.dart
	- graphql
		- graphql_client.dart
	- widgets
		- app_gradient_background.dart
- features
	- home
		- presentation
			- home_shell_page.dart
	- tasks
		- data
			- graphql
				- queries.dart
				- mutations.dart
			- models
				- task.dart
		- presentation
			- task_list_page.dart
			- create_task_page.dart
			- edit_task_page.dart
	- categories
		- data
			- graphql
				- queries.dart
				- mutations.dart
			- models
				- category.dart
		- presentation
			- category_list_page.dart
			- create_category_page.dart
			- widgets
				- category_card.dart
		- functions_categories.dart

## Configuracion GraphQL

El cliente GraphQL se crea en:

- lib/core/graphql/graphql_client.dart

El endpoint se define en:

- lib/core/constants/api_constants.dart

Valor actual:

- http://localhost:8080/graphql

Nota importante:

- Web, iOS, desktop: localhost
- Android emulator: normalmente 10.0.2.2 (si tu backend corre en la maquina host)

## Flujo de navegacion

La app arranca en HomeShellPage, que usa un IndexedStack con dos tabs:

- Tareas
- Categorias

Eso mantiene el estado de cada tab al cambiar de una a otra.

## GraphQL: queries y mutations

### Tasks

Query principal:

- findAllTasks(deleted: false, offset, limit)

Mutations usadas:

- createTask
- updateTask
- toggleTask
- toggleDeleteTask

### Categories

Query principal:

- categories(offset, limit)

Mutations usadas:

- createCategory
- updateCategory
- toggleDeleteCategory

## Paginacion con GraphQL (seccion clave)

Esta app pagina en frontend usando offset + limit, y el backend responde pageInfo.

### Inputs enviados

En cada Query se envian variables:

- offset: indice inicial de la pagina actual
- limit: cantidad de elementos por pagina

Ejemplos actuales:

- Tasks: limit = 5
- Categories: limit = 8

### Datos de pageInfo que llegan del backend

Para tasks:

- offset
- limit
- totalCount
- hasNextPage
- hasPreviousPage
- taskCompleted

Para categories:

- offset
- limit
- totalCount
- hasNextPage
- hasPreviousPage

### Calculo de pagina actual en frontend

- currentPage = (offset ~/ limit) + 1
- totalPages = (totalCount + limit - 1) ~/ limit

### Navegacion de paginas

Boton anterior:

- solo habilitado si hasPreviousPage es true
- nuevo offset = max(0, offset - limit)

Boton siguiente:

- solo habilitado si hasNextPage es true
- nuevo offset = offset + limit

### Refetch y consistencia de datos

Cada lista usa fetchPolicy: networkOnly para leer siempre desde red.

Ademas:

- despues de crear/editar/borrar/toggle, se llama refetch() de la Query activa
- al borrar categoria, tambien se dispara una query de tasks para sincronizar datos relacionados

Resultado: UI y backend quedan alineados aunque haya cambios cruzados entre tabs.

## Componente CategoryCard

CategoryCard se movio a un componente dedicado:

- lib/features/categories/presentation/widgets/category_card.dart

Incluye:

- estado local de edicion
- validacion de nombre
- guardado async
- estados visuales de loading

## Helpers de categorias

Se centralizo logica de acciones en:

- lib/features/categories/functions_categories.dart

Ahi viven:

- crear categoria
- borrar categoria
- toggle categoria
- renombrar categoria
- dialog de info
- refetch de tasks tras borrar categoria

## Como correr el proyecto

1. Instalar dependencias

```bash
flutter pub get
```

2. Levantar tu backend GraphQL en el endpoint configurado

3. Correr app

```bash
flutter run
```

Para web:

```bash
flutter run -d chrome
```

## Troubleshooting rapido

### No carga datos

- Revisar que backend este arriba en el endpoint correcto
- Revisar CORS si corres en web
- Revisar que schema tenga queries/mutations esperadas

### Paginador no cambia pagina

- Verificar que pageInfo.hasNextPage y hasPreviousPage lleguen bien
- Verificar que totalCount sea correcto en backend
- Verificar offset/limit enviados en variables de query

### Cambios no se reflejan al volver de otra pantalla

- Confirmar que se ejecuta refetch() al volver
- Confirmar fetchPolicy: networkOnly en la Query

## Mejoras sugeridas

- Agregar pruebas widget para paginacion y refetch
- Reemplazar prints por logger estructurado
- Agregar manejo de errores por tipo (network, GraphQL, validacion)
- Mover strings de UI a archivos de localizacion
