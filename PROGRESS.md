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

### Fase 3 — Power user — **CERRADA 2026-10-14**
- ✓ Compartir nota vía share sheet de Android
- ✓ Notas privadas (palabra clave + sesión de 5 min, lock on background,
  aislamiento total del flujo principal)
- ✓ Recordatorios locales (con permiso Android 13+, cancel on delete,
  leak-safe en privadas)
- Bloqueo con biometría (descartado: las notas privadas cubren el caso
  con contraseña, biometría no es necesario si el usuario ya tiene PIN)
- Widget Android (atajo en home screen)
- Ordenamiento flexible (modificación, creación, título, color)

### Fase 4 — Export + Spotify
- ✓ Exportar nota individual a `.txt` (texto plano) o `.md` (markdown)
  vía share sheet de Android
- Exportar carpeta completa a ZIP (vía `archive` — cada nota como PDF
  + carpeta de imágenes)
- Vincular canciones de Spotify a una nota (OAuth PKCE + Web API),
  con preview de 30s reproducible desde la nota

### Sesión 2026-10-15 — Fase 4: export individual
- Nuevo `lib/features/notes/note_exporter.dart`:
  - `NoteExportFormat { markdown, text }`.
  - `NoteExporter.toText(note)`: arma título + bodyPlain (mismo formato que
    el Compartir plain actual).
  - `NoteExporter.toMarkdown(note)`: parsea `bodyDelta` con
    `Operation.fromJson` (paquete `dart_quill_delta` reexportado por
    `flutter_quill/quill_delta.dart`). Render por líneas con:
    - **Bloque**: H1–H6 (`#` x nivel), blockquote (`> `), code-block
      (envoltura ``` ```), bullet/ordered list, check list `- [x] / - [ ]`.
    - **Inline**: bold (`**x**`), italic (`_x_`), strike (`~~x~~`),
      underline (`<u>x</u>`, sin markdown estándar), code (`` `x` ``),
      link (`[x](url)`).
    - Embeds: `image` → `![caption](path)`, `video` → 🎬 path.
    - Orden de wrap de inline (de inner a outer): code → italic → bold →
      strike → underline → link. Esto garantiza anidamiento correcto
      (ej. `**_x_**` en vez de `_**x**_`).
    - Si el delta no parsea, fallback a `toText`.
  - `NoteExporter.exportFile(note, format)`: escribe el contenido a
    `getTemporaryDirectory()/exports/<title> (<id>).<ext>` y devuelve
    un `XFile` con `mimeType` (`text/markdown` o `text/plain`).
  - `NoteExporter.share(note, format: …)`: `SharePlus.instance.share`
    con `files: [XFile]` y `subject` = título (o "Nota").
  - `NoteExporter.showExportSheet(context, note)`: helper que muestra el
    bottom sheet de selección de formato y delega a `share`. Captura
    el `sharePositionOrigin` del `context` para iPad. Si la nota está
    vacía, snackbar "La nota no tiene contenido para exportar".
- Nuevo `ExportEmptyException` para distinguir "nota vacía" de
  otros errores de I/O.
- Botón **"Exportar"** en el options sheet (long-press) de:
  - `NotesListScreen._showActions` — entre "Compartir" y "Marcar como
    privada". Abre `NoteExporter.showExportSheet`.
  - `FolderDetailScreen._showNoteActions` — entre "Compartir" y el
    toggle de privadas. Mismo helper.
  - `PrivateNotesScreen._showActions` — entre "Compartir" y "Quitar de
    privadas". Mismo helper.
- Icono: `Icons.file_download_outlined` con chevron `Icons.chevron_right`
  para señalar que abre submenú. Submenú: `Icons.description_outlined`
  (Markdown) y `Icons.text_snippet_outlined` (Texto plano), con subtitle
  corto.
- Tests: nuevo `test/note_exporter_test.dart` con 13 casos que cubren
  toText (3), toMarkdown para bold/italic, H1, listas (bullet/ordered/
  checked/unchecked), blockquote, link, imagen, y fallback a texto
  cuando el delta no parsea. Todos pasan, `flutter analyze` sin issues.
- APK debug compila OK (249 MB).

### Extras (ideas diferidas, no en roadmap activo)
- Widget Android (atajo en home screen)
- Backlinks entre notas
- Dibujo libre / sketches
- IA / resúmenes
- Biometría local (huella / cara) — sustituido por la palabra clave
  de notas privadas

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

### Fase 3 — Recordatorios locales (2026-10-14)
- Dependencias añadidas:
  - `flutter_local_notifications: ^22.3.2`
  - `timezone: ^0.11.2`
  - `flutter_timezone: ^5.1.1`
- Android (manifest):
  - `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`,
    `RECEIVE_BOOT_COMPLETED`, `WAKE_LOCK`, `VIBRATE`
  - `coreLibraryDesugaring = true` + `desugar_jdk_libs:2.1.4` en
    `app/build.gradle.kts` (requerido por `flutter_local_notifications` 18+)
- `NoteEntity.reminderAt: DateTime?` añadido (con índice). Migración
  automática — null por defecto en notas existentes.
- `NotesRepository`:
  - `setReminder(id, DateTime?)`
  - `getActiveWithReminders()` para re-agendar al arrancar la app
- Nuevo `lib/features/reminders/`:
  - `reminders_service.dart`: `RemindersService.instance` (singleton).
    - `init()`: configura timezone (vía `FlutterTimezone.getLocalTimezone`
      → `tz.getLocation(info.identifier)`), inicializa el plugin con
      `AndroidInitializationSettings('@mipmap/ic_launcher')` y crea el
      canal `note_reminders` con importancia HIGH.
    - `requestPermission()`: para Android 13+ (POST_NOTIFICATIONS).
    - `schedule({noteId, when, title, body, isPrivate})`:
      `zonedSchedule` con `androidScheduleMode: inexactAllowWhileIdle`
      (no requiere el permiso "alarmas y recordatorios" del sistema,
      puede llegar con algunos minutos de retraso). El payload lleva
      el `noteId` para deep-link al tap. Si la nota es privada, el
      título de la notificación es genérico ("Tienes un
      recordatorio") y el body es "Toca para abrir la nota" — no
      leak del contenido.
    - `cancel(noteId)`, `cancelAll()`.
    - `tappedNoteId: ValueNotifier<int?>` que se setea en
      `onDidReceiveNotificationResponse` cuando el usuario toca la
      notificación.
  - `reminder_picker.dart`: `showReminderPicker(context)` — date +
    time picker (24h). Valida que la fecha sea en el futuro.
    `formatReminder(when)` devuelve "Hoy 18:30", "Mañana 09:00", o
    "25/10/2026 18:30".
- `main.dart`: después de abrir Isar, llama a `RemindersService.init()`
  y re-agenda los recordatorios activos (sobreviven reinicios).
- `app.dart` (ahora `ConsumerStatefulWidget`): escucha
  `RemindersService.tappedNoteId` y navega a `/edit/$id` cuando se
  setea. También maneja el caso "app launched from notification"
  vía `getNotificationAppLaunchDetails`.
- Opciones de UI:
  - `NotesListScreen`, `FolderDetailScreen`, `PrivateNotesScreen`
    options sheets: "Programar recordatorio" / "Cambiar" (con
    `formatReminder` como subtitle) / "Quitar". Permiso se pide al
    programar.
  - `EditorScreen` AppBar: nuevo `PopupMenuButton` con icono
    `notifications_outlined` / `notifications_active_outlined`
    según el estado, mismo flujo.
- `NoteCard`: bell icon (`notifications_active_outlined`) junto al
  título cuando `reminderAt != null` y la nota no está locked.
- Cancelación de recordatorio en todos los paths de borrado:
  `softDelete` (lista, folder, editor), `permanentDelete` (trash
  sheet, trash swipe, trash empty indirecto via reschedule, editor
  para privadas, private notes screen).
- Si la nota se marca como privada y tenía recordatorio, se cancela
  (evita leak del título en la notif). Al desmarcar, el usuario
  tiene que reprogramar manualmente.

### Fase 3 — Notas privadas sin tab en el nav (2026-10-14)
- **Tab de Privadas eliminado del bottom nav**. Vuelve a 3 tabs
  (Notas / Carpetas / Papelera). El acceso a notas privadas es
  deliberadamente indirecto: solo desde Ajustes, y solo después de
  escribir la palabra clave.
- `app_router.dart`:
  - `/private` movido del `ShellRoute` a una ruta top-level con
    `parentNavigatorKey: _rootNavigatorKey` (sin bottom nav, con
    back por defecto del AppBar).
- `SettingsScreen` — sección "Notas privadas" rediseñada:
  - El tile principal muestra el estado (Bloqueada / Desbloqueada).
    Si está bloqueada, tap → `PasswordDialog` verify. Si está
    desbloqueada, tap → navega a `/private`.
  - **Cuando está desbloqueada**, debajo del tile aparece una fila
    con dos botones: "Ver notas privadas" (FilledButton primario,
    navega a `/private`) y "Bloquear" (OutlinedButton, cierra la
    sesión manualmente y muestra snackbar de confirmación).
  - "Cambiar clave" y "Desactivar" siguen en su propia fila abajo,
    disponibles siempre.
- Flujo completo: Ajustes → "Notas privadas" (verifica con clave) →
  aparece "Ver notas privadas" → navega a la lista. Para volver a
  bloquear, o se usa el botón "Bloquear" de ajustes, o el icono
  `lock_outline` del AppBar de la pantalla de privadas, o se espera
  al TTL de 5 min / app en background.

### Fase 3 — Notas privadas rediseñadas (2026-10-14)
- **Cambio mayor de modelo**: las notas privadas ahora son una sección
  completamente aislada. NO aparecen en la lista principal, ni en
  búsqueda, ni en el detalle de carpetas, ni en la papelera. La única
  forma de acceder a ellas es desde el nuevo tab **"Privadas"** en el
  bottom nav. Una nota privada eliminada va directo a
  `permanentDelete` — no hay papelera, no se puede recuperar.
- `NotesRepository`:
  - `watchActive()`, `watchByCategory()`, `watchTrash()` y `search()`
    ahora filtran `isPrivateEqualTo(false)`.
  - Nuevo `watchPrivateActive()` con `deletedAtIsNull().isPrivateEqualTo(true)`,
    mismo orden (pinned desc, updatedAt desc).
- Nuevo `privateNotesListProvider` en `notes_providers.dart`.
- Nuevo `lib/features/private_notes/private_notes_screen.dart` con tres
  estados:
  - **Sin clave**: empty state con CTA "Ir a Ajustes".
  - **Bloqueado** (sesión expirada o nunca abierta): empty state con
    botón "Desbloquear" que abre el `PasswordDialog` en modo verify.
  - **Desbloqueado**: lista de notas privadas con el mismo `NoteCard`.
    AppBar muestra un icono `lock_outline` para volver a bloquear
    manualmente.
  - Options sheet de la lista: Fijar / Cambiar color / Compartir /
    **Quitar de privadas** (`setPrivate(id, false)`) /
    **Eliminar definitivamente** (con `showConfirmDialog` destructivo,
    sin pasar por papelera).
- Router: nueva ruta `/private` como segundo tab del shell.
- Bottom nav: 4 tabs (Notas / Privadas / Carpetas / Papelera),
  `BottomNavigationBarType.fixed` para que quepan las labels.
- `EditorScreen._delete()` ahora pide confirmación (`showConfirmDialog`)
  y, si la nota es privada, hace `permanentDelete` con diálogo destructivo
  ("Esta nota privada se borrará para siempre y no se puede recuperar").
  Para notas regulares sigue siendo "Mover a papelera" con el mensaje
  de los 30 días.
- `NoteCard` mantiene el "tratamiento locked" como red de seguridad
  (icono lock, "Nota privada" en cursiva, "•••••• contenido
  protegido"). Con el filtrado del repo, ya no debería verse en la
  lista principal nunca, pero el check se queda por defensa en
  profundidad.

### Fase 3 — Notas privadas (2026-10-14)
- `crypto: ^3.0.6` añadido a pubspec (SHA-256 para hashear la palabra clave)
- `NoteEntity` ahora tiene `bool isPrivate = false`. Migración de Isar
  automática (campo nuevo → default false en notas existentes).
- `NotesRepository.setPrivate(id, isPrivate)` añadido.
- Nuevo módulo `lib/features/private_notes/`:
  - `private_notes_controller.dart`:
    - `PrivateNotesState { hasPassword, unlockedUntil }` con
      `isUnlocked` derivado (false si TTL expirado).
    - `PrivateNotesController` (Notifier): `verify`, `setPassword`,
      `changePassword({current, next})`, `removePassword(current)`,
      `removeAfterVerified()`, `lock`. La sesión dura `sessionTtl = 5 min`
      desde el último verify/change/set exitoso.
    - `sharedPreferencesProvider` exportado (Provider) con override en
      `main.dart` (se carga `SharedPreferences.getInstance()` una vez).
    - Hash de la palabra clave con `sha256.convert(utf8.encode(input))`,
      almacenado en `shared_preferences` bajo `private.notes.passwordHash`.
  - `password_dialog.dart`:
    - `showPasswordDialog(context, ref, mode, title?)` con 3 modos:
      `set` (clave nueva + repetir), `change` (actual + nueva + repetir),
      `verify` (solo la clave).
    - Devuelve `PasswordDialogResult { success, message? }` para que la
      UI muestre snackbars con el motivo del fallo.
    - Mínimo 4 caracteres al crear/cambiar.
- `NoteCard` ahora es `ConsumerWidget`. Si la nota es `isPrivate` y la
  sesión está bloqueada, muestra:
  - Icono `lock` junto al título
  - Título reemplazado por **"Nota privada"** (cursiva)
  - Preview reemplazado por **"•••••• contenido protegido"**
  - Sin heat point de color
  Cuando la sesión está desbloqueada, se ve normal.
- `SettingsScreen` tiene ahora una sección **"Notas privadas"**:
  - Si no hay clave: tile "Activar notas privadas" → dialog set
  - Si hay clave: tile "Notas privadas" muestra el estado (activada,
    sesión desbloqueada) y un icono de candado. Tap alterna lock/unlock
    (si está bloqueada, pide verify; si está desbloqueada, la bloquea
    al instante). Debajo: dos botones "Cambiar clave" y "Desactivar".
- `NotesListScreen` y `FolderDetailScreen` muestran en su options sheet
  (long-press) la opción **"Marcar como privada"** / **"Quitar de
  privadas"** solo si `hasPassword` es true.
- `EditorScreen._bootstrap` ahora: si la nota a abrir es privada y la
  sesión está bloqueada, muestra el `PasswordDialog` (verify). Si
  cancela o falla, snackbar con el motivo y `context.pop()`.
- `app.dart` ahora es `ConsumerStatefulWidget` con `AppLifecycleListener`
  que llama a `lock()` en `onPause`, `onInactive` y `onHide` — la
  sesión se cierra cuando la app pasa a background.
- Búsqueda: las notas privadas aparecen en los resultados pero se ven
  locked (mismo `NoteCard`). Tradeoff conocido: el índice de Isar
  matchea por contenido aunque esté bloqueada — se documenta como
  limitación aceptable para el modelo de amenaza "shoulder surfing".
  Si más adelante se quiere evitar, se puede filtrar en `search()` por
  `isPrivate == false` cuando la sesión esté bloqueada.

### Fase 3 — Confirmaciones de borrado (2026-10-14)
- Nuevo `lib/shared/widgets/confirm_dialog.dart`:
  - `showConfirmDialog(context, title, message, confirmLabel, cancelLabel,
    destructive, icon)` — `AlertDialog` con botón `FilledButton` que vira a
    `colorScheme.error` cuando `destructive: true`, devolviendo `bool`.
  - Cierra con `Navigator.pop` y devuelve `false` por defecto si se descarta
    el dialog (tap fuera / back).
- Confirmaciones añadidas:
  - `NotesListScreen`: "Mover a papelera" → "¿Mover a papelera? Podrás
    restaurarla desde la papelera durante 30 días…" (no destructivo, recuperable)
  - `FolderDetailScreen`: mismo mensaje
  - `TrashScreen`: "Eliminar definitivamente" (sheet) → "¿Eliminar
    definitivamente? Esta nota se borrará para siempre y no se puede
    recuperar." (`destructive: true` → botón rojo)
  - `TrashScreen`: swipe-to-delete via `Dismissible.confirmDismiss` →
    mismo dialog destructivo. Si el usuario cancela, el `Dismissible`
    devuelve la nota a su sitio automáticamente
  - `TrashScreen`: "Vaciar papelera" → unificado con el helper, ahora
    muestra el conteo ("Se eliminarán N notas de forma permanente…")
- El background del `Dismissible` ahora muestra un fondo rojo tenue con
  icono `delete_forever` en `colorScheme.error` (antes era `Container()`
  vacío, swipe invisible). Funciona en ambas direcciones.

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

1. **Fase 4 (continuación)**: export carpeta completa a ZIP con PDF
   de cada nota + imágenes embebidas
2. **Fase 4**: Spotify (OAuth PKCE + Web API) — confirmar con el usuario
   si tiene `client_id` propio o usamos placeholder, y si solo tracks o
   también playlists/albums

## Convenciones

- Código en inglés, UI en español
- Sin emojis en código (salvo que se pidan explícitamente)
- Riverpod para todo estado
- Auto-guardado siempre, sin botones "guardar"