# note-think — Project Brief

App móvil de notas, **local-first**, Android primero e iOS después desde el mismo código.

## Stack

| Capa | Tecnología |
|------|------------|
| Framework | Flutter |
| State | Riverpod |
| Navegación | go_router |
| DB local | Isar (full-text search nativo) |
| Archivos | path_provider |
| Diseño | flutter_neumorphic (Neumorfismo) |
| Editor rico | flutter_quill |
| Imágenes | image_picker |
| Export PDF | pdf + printing |
| Export ZIP | archive |
| Notificaciones | flutter_local_notifications |
| Biometría | local_auth |
| Widget Android | home_widget |
| Compartir | share_plus |

## Sistema de diseño

### Paleta — Light mode
- `#283618` — botones, títulos, texto
- `#fefae0` — fondo

### Paleta — Dark mode (variante afinada)
- `#1a1f10` — fondo
- `#e8e4d0` — texto / detalles
- `#283618` — elementos secundarios / superficies

### Paleta de notas (4 colores)
- `#A69F4D` — oliva / amarillo
- `#44442A` — oliva oscuro
- `#663920` — marrón
- `#2C100D` — marrón muy oscuro

Aplicados como **gradiente radial en la esquina superior derecha** del card de la nota, desvaneciendo hacia el fondo. La nota nace **sin punto de calor** — el usuario decide activarlo/elegir el color después.

### Estilo: Neumorfismo
- Sombras suaves (claras + oscuras) sobre el fondo
- Monocromático, integra bien con la paleta terrenal
- Sensación táctil tipo papel — coherente con la metáfora de notas

## Funcionalidades

### Fase 1 — Base (MVP)
- Setup Flutter + tema neumórfico claro/oscuro
- Isar: modelos y DB local
- CRUD notas (crear, listar, editar, borrar)
- Editor rico con flutter_quill (negritas, cursivas, listas, encabezados, imágenes, links)
- Lista con punto de calor opcional por nota
- Búsqueda full-text
- Papelera (soft delete, auto-borrado a 30 días, recuperable)

### Fase 2 — UX
- Notas fijadas (pin) — acceso rápido
- Color de nota (picker con los 4 colores)
- Vista lista / grid toggleable
- Filtros rápidos (carpeta, color, fijadas)
- Auto-guardado (sin botón "guardar")
- Ordenamiento flexible (modificación, creación, título, color)

### Fase 3 — Power user
- ✓ Compartir nota vía share sheet de Android
- Bloqueo con biometría (por nota o app completa)
- Recordatorios locales (notificación a fecha/hora)
- Widget Android (atajo en home screen)
- Ordenamiento flexible (modificación, creación, título, color)

### Fase 4 — Export
- Exportar nota individual a PDF (vía paquete `pdf` + `printing`)
- Exportar carpeta completa a ZIP (vía `archive` — cada nota como PDF + carpeta de imágenes)

### Descartado a propósito (mantener simple)
- Colaboración en tiempo real
- IA / resúmenes
- Backlinks entre notas
- Dibujo libre / sketches

## Estructura de carpetas objetivo

```
lib/
  main.dart
  app.dart
  core/
    theme/         (paleta, neumorfismo, dark/light)
    db/            (setup Isar, modelos, migraciones)
    storage/       (path_provider para imágenes)
    router/        (go_router)
  features/
    notes/         (CRUD + editor + lista + búsqueda)
    folders/       (carpetas)
    tags/          (etiquetas)
    search/        (búsqueda full-text)
    trash/         (papelera)
    export/        (PDF + ZIP)
  shared/
    widgets/       (neumorphic button, card, input, etc.)
    utils/
```

## Estado actual (Fase 1)

Hecho y compilando (APK debug):
- Tema neumórfico claro/oscuro, tipografía Inter, paletas definidas arriba
- Isar (`isar_community` 3.3.2), CRUD de notas, papelera con restaurar/eliminar/vaciar
- Editor Quill con imágenes, auto-guardado con debounce de 500 ms e indicador (spinner / palomita tocable)
- Navegación: bottom nav (Notas / Carpetas / Papelera), búsqueda y ajustes desde el AppBar
- Punto de calor opcional por nota (selector de 4 colores)
- Card de nota muestra `Creada <fecha>` y, si difiere, `editada <fecha>`
- Toolbar Quill: al seleccionar una herramienta (negrita, cursiva, listas, etc.) los colores
  se **invierten** (fondo = color de texto, icono = color de fondo) en vez del círculo oscuro
  por defecto de M3 `IconButton.filled`

### Carpetas (Fase 1 cerrada, sin tags)
- Pestaña "Carpetas" en el bottom nav (antes "Categorías")
- Crear / renombrar / eliminar carpeta desde la lista
- Tocar una carpeta abre `FolderDetailScreen` con sus notas y un FAB para crear
  una nota dentro (la nueva nota queda asignada a esa carpeta vía `folderId` en la URL)
- Long-press en una nota → bottom sheet con: Fijar, Cambiar color, **Agregar a carpeta**,
  Quitar de carpeta (solo si ya está en una), Mover a papelera
- "Agregar a carpeta" abre un bottom sheet con buscador, lista alfabética de carpetas
  y la opción "Crear <nombre>" cuando hay texto en el buscador
- Al eliminar una carpeta, las notas que tenía dentro se conservan y solo se les
  desasigna `categoryId` (no se borran ni se van a la papelera)
- `NoteEntity.categoryId` ahora tiene `@Index()` para filtrar eficiente por carpeta

## Pendientes y bugs conocidos

### Sesión 2026-10-13
- Card de nota ahora muestra fecha de creación y, si fue editada en otro minuto, fecha de edición
- Toolbar Quill: las herramientas seleccionadas invierten colores en lugar de usar el círculo oscuro
  de `IconButton.filled` (M3). Estilo controlado vía `QuillIconTheme` en `QuillSimpleToolbarConfig`
- Carpetas (sin tags): CRUD de carpetas, detalle de carpeta, asignación de notas vía
  bottom sheet "Agregar a carpeta" con buscador y crear-en-linea, índice Isar en `categoryId`,
  desasignación en cascada al borrar carpeta
- Fix: botón "Crear nueva carpeta" del sheet "Agregar a carpeta" ahora pide el nombre
  mediante un diálogo cuando el buscador está vacío (antes no hacía nada porque
  `query.trim()` era `''` y la función salía temprano)

### Cierre de Fase 1
- Papelera: `purgeExpiredTrash()` borra notas con `deletedAt < now - 30 días` y se ejecuta
  en el arranque de la app (`main.dart`); `NotesRepository.trashRetention` documenta la constante
- Búsqueda: tokeniza el término y usa `group()` con `titleStartsWith` OR `bodyPlainElementStartsWith`
  por cada token — todo respaldado por los índices `title` y `bodyPlain` de Isar
  (antes hacía `findAll()` y filtraba en memoria)
- Long-press en nota de papelera: ahora abre el mismo sheet que el tap (restaurar / eliminar definitivamente)
- Contador `N notas` (singular/plural) junto al nombre de cada carpeta, derivado de
  `notesByFolderProvider` y expuesto vía `noteCountByFolderProvider` en `categories_providers.dart`

### Sesión 2026-10-14
- Búsqueda por palabras dentro de la nota: ampliado a hybrid prefix+contains. Cada token
  matchea con `titleStartsWith` OR `titleContains` OR `bodyPlainElementStartsWith` OR
  `bodyPlainElementContains` (todos case-insensitive, todos AND'd entre tokens). El prefijo
  sigue indexado; el contains es filter nativo de Isar (no vuelve a filtrar en Dart).

### Fase 2 — Filtros rápidos (2026-10-14)
- Nuevo módulo `lib/features/notes/notes_filter.dart`:
  - `NotesFilter` (inmutable): `categoryId: int?`, `accentHex: String?`, `pinnedOnly: bool`.
    Sentinel `NotesFilter.noAccentSentinel = '__none__'` distingue "sin color" de "todos los
    colores" en el mismo campo.
  - `NotesFilterController` (Notifier): `setCategory / setAccent / setPinnedOnly / clear`.
  - `filteredNotesProvider`: combina `notesListProvider` + `notesFilterProvider` y filtra
    en memoria. Es correcto para Fase 2; si se nota lento con miles de notas se mueve
    a Isar con un query compuesto.
- `lib/features/notes/filter_sheets.dart`: tres bottom sheets de selección (carpeta,
  color, fijadas) con `setState` y radio visual de selección. Cada uno expone una
  función `showXxxFilterSheet(context, ref)`.
- `lib/features/notes/filter_bar.dart`: barra horizontal scrollable bajo el AppBar con
  tres chips neumórficos (Carpeta / Color / Fijadas). Cuando hay algún filtro activo
  el chip se ve "activo" (fondo + borde) y se suma un cuarto chip "Limpiar" con icono
  de X. El chip de color muestra el swatch elegido (o el icono de bloque para "sin color").
- `NotesListScreen`: ahora observa `filteredNotesProvider` y `notesFilterProvider`. Cuando
  hay notas pero los filtros no matchean, muestra un empty state específico con
  botón "Limpiar filtros" (vs. el empty state original "Aún no hay notas" cuando no
  hay nada).
- Filtros son **de sesión** (no persisten al cerrar la app) — más simple y suficiente
  para Fase 2. Si se quiere persistir, candidato natural: `shared_preferences`.

### Fase 2 — Toggle lista/grid (2026-10-14)
- Nuevo módulo `lib/features/notes/notes_layout.dart`:
  - `enum NotesLayout { list, grid }`
  - `NotesLayoutController` (`AsyncNotifier<NotesLayout>`) carga y guarda la preferencia
    en `shared_preferences` bajo la clave `notes.listLayout`. Default: `list`.
  - `notesLayoutProvider` expone el estado; `toggle()` cambia entre los dos.
- `NoteCard`: nuevo parámetro opcional `compact: bool`. En modo compacto:
  - Padding reducido (14/12/14/12 vs 18/16/18/18)
  - Título `titleSmall` en vez de `titleMedium`
  - Preview a 1 línea (vs 2) y `bodySmall` (vs `bodyMedium`)
  - Fecha de edición oculta (solo "Creada …") para ahorrar altura
  - Heat point de 80×80 (vs 120×120) para no robarle espacio al texto
- `NotesListScreen`:
  - Botón nuevo en el AppBar entre "Buscar" y "Más": icono dinámico
    (`grid_view_outlined` cuando está en lista → invita a cambiar a grid;
    `view_agenda_outlined` cuando está en grid → invita a volver a lista)
    con tooltip contextual.
  - Body refactorizado: extraídos `_NotesList` y `_NotesGrid` a widgets privados
    que reciben las notas + callbacks. `_NotesGrid` usa
    `SliverGridDelegateWithMaxCrossAxisExtent(200)` para que se adapte al ancho
    de pantalla (1 col muy estrecho, 2 cols estándar, 3+ en tablets).
- La preferencia **persiste** entre arranques de la app (a diferencia de los filtros,
  que son de sesión).

### Fase 3 — Compartir nota (2026-10-14)
- `share_plus: ^13.3.1` añadido a `pubspec.yaml` (estaba en la tabla de stack
  del brief pero nunca se había instalado)
- Nuevo `lib/features/notes/note_share.dart`:
  - `NoteShare.serialize(note)` arma el texto: título (trim) + doble salto + body
    (líneas no vacías de `bodyPlain` unidas con `\n`). Si título y body están
    vacíos devuelve `''`.
  - `NoteShare.share(context, note, sharePositionOrigin)`:
    - Si la nota está vacía, snackbar "No hay nada que compartir" y no abre
      el sheet del sistema.
    - Si no, llama a `SharePlus.instance.share(ShareParams(text, subject))`.
    - `sharePositionOrigin` es el rect del ListTile que disparó la acción
      (necesario en iPad, ignorado en Android); se captura del `BuildContext`
      del sheet antes de cerrarlo.
- Botón "Compartir" añadido al options sheet (long-press) de:
  - `NotesListScreen._showActions` — entre "Quitar de carpeta" y "Mover a papelera"
  - `FolderDetailScreen._showNoteActions` — entre "Quitar de esta carpeta" y
    "Mover a papelera"
- Icono: `Icons.ios_share` (consistente con el estilo del sistema; el share
  sheet de Android lo muestra igual que `share_outlined`).
- Subject del share: el título de la nota, o "Nota" si no tiene.
- Por ahora comparte solo texto plano (sin imágenes embebidas). Las imágenes
  inline de Quill quedan serializadas como texto vacío; el export rico
  (PDF/ZIP) es la Fase 4.

### Fase 2 — Ordenamiento flexible (2026-10-14)
- Nuevo módulo `lib/features/notes/notes_sort.dart`:
  - `enum NotesSortField { modified, created, title, color }`
  - `enum NotesSortDirection { asc, desc }`
  - `NotesSort` (inmutable) con `field`, `direction`, helpers `fieldLabel` /
    `shortLabel` (chip-friendly) / `isDefault` (true si es modified-desc).
  - `NotesSortController` (`AsyncNotifier<NotesSort>`) persiste en
    `shared_preferences` bajo `notes.sort.field` y `notes.sort.direction`.
    Default: `modified, desc`. Métodos: `setField`, `setDirection`, `reset`.
  - `displayedNotesProvider`: encadena `filteredNotesProvider` + `notesSortProvider`
    y aplica el sort **siempre con pinned primero**: parte en (fijadas, no fijadas),
    ordena cada grupo por el criterio elegido, concatena. Dentro de cada grupo el
    empate se rompe por `updatedAt` en la dirección opuesta al sort principal.
  - Para "Color" el orden es por índice en `AppColors.noteAccents`; las notas sin
    color se mandan al final (sentinel 9999) para no mezclarse con las coloreadas.
  - Al cambiar de campo, la dirección se ajusta al default sensato del campo
    (modified/created → desc, title/color → asc). El usuario puede invertirla luego.
- `lib/features/notes/sort_sheet.dart`: bottom sheet con dos secciones ("POR" y
  "DIRECCIÓN"). Cada campo muestra icono + nombre + hint corto. La dirección es
  un segmented control neumórfico (ascendente / descendente). Aparece botón
  "Restablecer" solo si no se está en el default.
- `NotesFilterBar`: 4º chip "Ordenar" con icono dinámico según campo
  (`history` / `history_toggle_off` para modified, `event_outlined` para created,
  `sort_by_alpha` para título, `palette_outlined` para color) y label compacto
  ("Recientes", "Antiguas", "Creación ↓/↑", "A-Z"/"Z-A", "Por color"). Se marca
  "activo" solo cuando NO se está en el default (modified-desc), para no inflar
  la barra cuando el usuario nunca tocó el orden.
- `NotesListScreen` ahora observa `displayedNotesProvider` en vez de
  `filteredNotesProvider`. La barra de filtros sigue mostrando los chips de
  filtro (carpeta/color/fijadas) más el de orden — todos en el mismo scroll.

### Pendientes de Fase 1
- _(ninguno — verificado en dispositivo real el 2026-10-14)_

### Backlog — optimizaciones futuras
- **Búsqueda FTS por pre-tokenización** (opción 3, archivada el 2026-10-14 por si la búsqueda
  se vuelve lenta con miles de notas): añadir un campo indexado `bodyWords: List<String>` a
  `NoteEntity` con las palabras únicas normalizadas (lowercase, sin acentos, longitud ≥ 2) del
  título + `bodyPlain`, mantenido en cada `upsert` y reconstruido en una migración
  one-shot de los datos existentes. La query pasaría a hacer solo
  `bodyWordsElementStartsWith(token).or().bodyWordsElementContains(token)` (todo indexado).
  Tradeoffs: +1 escritura por guardado, +tamaño en disco, migración inicial obligatoria. Solo
  aplicaría si la rama `contains` sin índice se nota lenta en datasets grandes.

### Ruido de logcat (no es un bug)
Los mensajes `InputConnectionAdaptor: The input method toggled cursor monitoring on/off` e
`ImeTracker ... onCancelled` los emite el teclado de Android al enfocar el editor.
No indican fallo y no se pueden silenciar desde la app; se filtran con `adb logcat -s flutter`.

## Bugs resueltos

- Nota que no se guardaba al reabrirla y añadir texto: al re-guardar se creaba un `NoteEntity` nuevo
  sin `createdAt` (campo `late`), Isar lanzaba una excepción y el `catch` la ocultaba.
  Ahora se parte de la nota existente y el error se registra con `debugPrint`.
- Excepción `!_debugLocked` al vaciar la papelera: los diálogos usaban el `context` equivocado en `Navigator.pop`.
- Guardado que se detenía tras la primera escritura: reemplazado por debounce real con `Timer`.

## Próximos pasos

1. **Fase 3 (continuación)**: bloquear con biometría, recordatorios, widget Android
2. **Fase 4 — Export**: PDF individual + ZIP de carpeta (estos sí incluirán imágenes)

## Convenciones

- Código en inglés, UI en español
- Sin emojis en código (salvo que se pidan explícitamente)
- Riverpod para todo estado
- Auto-guardado siempre, sin botones "guardar"