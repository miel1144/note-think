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

### Estilo: glassmorfismo — decisión pendiente (2026-10-16)
El usuario reportó que el neumorfismo actual se ve "tan plano" y pidió
evaluar pasar a glassmorfismo. Se levantaron tres caminos:

**A — No cambiar / más profundidad dentro del neumorfismo** (barato).
Subir `intensity` default de `NeuSurface` (1.0 → 1.3-1.5), pintar el
fondo con un gradient radial sutil, explotar más los heat points
(4 colores de nota). Mantiene la identidad "papel".

**B — Híbrido** (recomendado si se quiere refresh visual). Mantener
`NeuSurface` para cards/tiles (papel) + sumar `GlassSurface` con
`BackdropFilter` solo en overlays flotantes (AppBar, sheets, dialogs,
FAB chrome). Esfuerzo bajo, performance OK (2-3 surfaces blurred por
pantalla), jerarquía clara.

**C — Switch completo**. Reescribir `NeuSurface` → `GlassSurface` en
todos los sitios (~15 usos), sumar fondo gradient/blob, aceptar el
costo de performance o cachear con `ImageFiltered` + `RepaintBoundary`.
**Requiere test en device real antes de comprometer**. Solo si se
quiere un reset de identidad.

Tradeoffs generales a tener en cuenta:
- `BackdropFilter` es GPU-pesado en listas largas (Flutter docs lo
  desaconsejan sin cache). Notas con 20+ cards es el caso peor.
- Glass se ve mejor con fondo colorido. El fondo actual sólido
  (`#fefae0` / `#1a1f10`) hace que sin decoration se vea lechoso.
- La paleta terracota cálido es atípica para glass (lo común es
  azul/morado/cyan). Existe glass cálido pero compite con el blur
  nativo del OS y puede verse "iOS stock".
- Glass mata la metáfora "papel" — pasa a "panel de control".
- Texto sobre translúcido depende del contenido detrás; WCAG AA
  cuesta mantenerlo consistente.

**Estado**: pendiente de decisión del usuario. No se hizo ningún
cambio en código todavía.

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

### Fase 3 — Power user — **CERRADA 2026-10-14** (recordatorios movidos a Extras 2026-10-15)
- ✓ Compartir nota vía share sheet de Android
- ✓ Notas privadas (palabra clave + sesión de 5 min, lock on background,
  aislamiento total del flujo principal)
- Bloqueo con biometría (descartado: las notas privadas cubren el caso
  con contraseña, biometría no es necesario si el usuario ya tiene PIN)
- Widget Android (atajo en home screen)
- Ordenamiento flexible (modificación, creación, título, color)

### Fase 4 — Export + Spotify
- ✓ Exportar nota individual a `.txt` (texto plano) o `.md` (markdown)
  vía share sheet de Android
- ✓ Exportar nota individual a **PDF con imágenes embebidas** vía
  share sheet o guardando en `Downloads/NoteThink/`
- ✓ **Vincular canciones, playlists y albums de Spotify a una nota**
  (paste URL + oEmbed, sin OAuth ni client_id)
- ✓ Descargar **copia de seguridad ZIP (.zip)** desde Ajustes (cada nota
  como `.txt`, organizadas por carpeta — raíz para notas sueltas)
- ✓ Selección múltiple de notas (long-press) con acciones bulk:
  - **Carpeta**: picker reutilizado, ahora multi (`noteIds: […]`); añade
    fila "Quitar de carpeta" para sacar el batch
  - **Papelera**: confirmación única → `softDeleteBulk` (cancela recordatorios)
  - Toolbar "Seleccionar todas / Ninguna" solo afecta las notas visibles
    (respeta filtros / carpeta actual)

### Sesión 2026-10-15 — Fase 4: enlaces de Spotify (paste URL + oEmbed)
- **Tipo**: track + playlist + album (artist queda fuera del alcance v1).
- **Cómo se vincula**: el usuario pega una URL (`https://open.spotify.com/<track|playlist|album>/<id>`)
  o un URI (`spotify:<type>:<id>`) en un dialog. Se valida con regex,
  luego se hace `GET https://open.spotify.com/oembed?url=<encoded>`
  para obtener `type`, `title`, `author_name`, `thumbnail_url`.
  **Sin OAuth, sin client_id, sin login**. Limitación: depende de que
  Spotify mantenga el endpoint oEmbed (hoy público).
- **Acción al tocar el card**: deep link al URI `spotify:…` con
  `url_launcher` (cayendo a la URL `https://` si no hay app instalada).
  **Sin preview de 30s** en esta versión — queda como follow-up
  si se quiere (requeriría OAuth + Web API + audio SDK).
- **Modelos / DB**:
  - Nueva colección Isar `SpotifyLinkEntity` con `noteId` (index),
    `spotifyUri`, `spotifyUrl`, `type` (enum track/playlist/album),
    `title`, `subtitle`, `thumbnailUrl?`, `addedAt`.
  - `IsarService.open()` ahora incluye `SpotifyLinkEntitySchema`.
- **Repos / providers**:
  - `SpotifyRepository` con `watchByNote` (Stream), `addFromInput`
    (parse + oEmbed + put en una sola transacción),
    `remove / removeAllForNote`.
  - `spotifyRepositoryProvider` en `core/storage/repositories.dart`.
  - `spotifyLinksByNoteProvider` y `spotifyLinkCountByNoteProvider`
    (StreamProvider.family).
- **UI**:
  - **Editor screen** AppBar: nuevo `PopupMenuButton` con icono
    `music_note` que se pinta verde cuando la nota tiene ≥1 enlace.
    Opciones: "Vincular canción o playlist" y "Quitar todos (N)".
  - **Editor screen** body: nueva `_SpotifyLinksSection` arriba
    del campo de título. Si no hay links muestra una "tarjeta CTA"
    verde con borde que al tap abre el dialog. Si hay links, los
    lista como `SpotifyLinkCard` + un botón "Añadir otro".
  - **NoteCard**: icono `music_note` verde junto al título cuando
    la nota tiene ≥1 enlace y no está bloqueada.
  - **`SpotifyLinkCard`**: card verde con borde, icono del tipo
    (track/playlist/album), label "Canción"/"Playlist"/"Álbum",
    título + subtítulo, botón X para quitar.
  - **`AddSpotifyLinkDialog`**: `AlertDialog` con icono Spotify
    verde, text field con URL, botón "Vincular" que muestra
    spinner mientras hace el oEmbed.
- **Cascada de borrado**:
  - `permanentDelete` (nota): ahora borra todos los Spotify links
    de esa nota desde el editor y desde la papelera (Dismissible
    y options sheet).
  - `emptyTrash`: ahora retorna los IDs eliminados para que la UI
    borre los links correspondientes.
  - `purgeExpiredTrash` en `main.dart`: ahora retorna los IDs y se
    hace cleanup de los links huérfanos al arrancar.
- **Android**:
  - `AndroidManifest.xml`: `<queries>` adicionales para `spotify:`
    y `https:` (requerido por Android 11+ para `canLaunchUrl`).
  - `url_launcher: ^6.3.3` como dependencia nueva.
- **Tests**: 9 casos nuevos para `parseInput` (https track/playlist/
  album, URI spotify:, URL con query params, empty, inválida, artist
  no soportado, trim whitespace). Total: **25 tests pasan**,
  `flutter analyze` sin issues, APK debug compila.

### Sesión 2026-10-19 — Fix: long-press entraba al menú en vez de a selección
- **Bug reportado**: en device, long-press sobre una nota abría el menú de
  acciones (comportamiento heredado) en vez de entrar al modo selección.
  Causa: `_handleLongPress` siempre llamaba a `_showActions(...)` cuando
  `selection.enabled == false`, ignorando la nueva ruta de selección.
- **Fix** (`notes_list_screen.dart` + `folder_detail_screen.dart`):
  `_handleLongPress` ahora delega en `controller.enterWith(note.id)`
  cuando no se está en selección y delega en `toggle` cuando sí. El menú
  por nota deja de existir en esas pantallas.
- **Acceso a las acciones por nota (Fijar / Color / Compartir / Exportar)**:
  nuevo menú en el AppBar del editor (`_NoteActionsMenu`), entre
  `Spotify` y `Reminder`, con icono `more_vert`. Comportamiento:
  - **Fijar / Desfijar**: toggle de `pinned`, snackbar confirmando
  - **Añadir / Cambiar color** (la etiqueta cambia si la nota ya tiene color):
    abre `showNoteColorPickerSheet`
  - **Compartir**: `NoteShare.share`
  - **Exportar**: `NoteExporter.showExportSheet` (mismo flujo
    MD / TXT / PDF + Compartir / Guardar en Descargas)
- **Color picker extraído** a `lib/features/notes/color_picker_sheet.dart`
  (`showNoteColorPickerSheet(context, ref, note:)`), reusado por la lista,
  el detalle de carpeta y el editor. Se eliminaron las copias privadas
  `_ColorSwatch` / `_RemoveColor` / `_pickColor` / `_showActions` /
  `_showNoteActions` y los imports asociados (`app_colors.dart`,
  `note_share.dart`, `note_exporter.dart` en las pantallas).
- **Tests**: 52/52 siguen pasando; `flutter analyze` limpio.

### Sesión 2026-10-19 — Selección múltiple (bulk: carpeta + papelera)
- **Pedido**: poder seleccionar todas las notas (o unas cuantas) para
  moverlas a carpeta o a papelera de un solo gesto, sin repetir la
  acción nota por nota.
- **`NotesSelectionState`** (`lib/features/notes/notes_selection.dart`):
  estado inmutable `{enabled, selectedIds}` con `NotesSelectionController`
  (Notifier) que expone `enter`, `enterWith`, `toggle`, `selectAll`,
  `clearSelectionKeepingMode`, `exit`. Test pure-Dart (9 casos).
- **Repositorio**: `NotesRepository.setCategoryBulk(ids, categoryId)` y
  `softDeleteBulk(ids)` — un único `writeTxn` cada uno, usan
  `_col.getAll` + `putAll` (mucho más rápido que llamar al método single
  N veces). Devuelven el número de filas tocadas / los ids borrados
  respectivamente (sin recompilar la app para UX).
- **`FolderPickerSheet`**: API cambiada de `noteId` a
  `noteIds: List<int>` (assert non-empty); cuando el batch trae más de
  una nota, se quita el check de la fila "actual" (no tiene sentido
  marcar un folder único cuando hay un set diverso) y se añade una fila
  superior **"Quitar de carpeta"** (en rojo) que llama a
  `setCategoryBulk(ids, null)`. El sheet sigue funcionando en single-note
  (manteniendo el check de "current" y sin la fila extra).
- **UI selection**:
  - `NotesListScreen` y `FolderDetailScreen` pasaron a `ConsumerStatefulWidget`.
  - Long-press en una nota = entra al modo selección con esa nota marcada.
  - Tap (en modo) = toggle; long-press adicional = toggle también
    (sustituye al sheet de acciones mientras dure la selección).
  - AppBar alterna: normal vs **"X seleccionadas"** con close + chip
    "Todas/Ninguna" (afecta solo las notas VISIBLES, respetando filtros).
  - BottomNavigationBar nueva: barra inferior con dos `NeuSurface`
    grandes **"Carpeta"** y **"Papelera"**.
    - "Carpeta" abre un sheet mini con dos opciones: "Mover N notas a
      carpeta" → abre el folder picker multi; "Quitar N notas de
      carpeta" → `setCategoryBulk(null)` directo + snackbar.
    - "Papelera" → confirm + `softDeleteBulk` + cancela recordatorios
      de las notas afectadas (`RemindersService.cancel` por id) + snackbar.
  - `PopScope` en cada pantalla: si se está en selección y el usuario
    hace back, primero se sale de la selección (no se sale de la pantalla).
  - `Dismissible` swipe-to-delete **deshabilitado** mientras se está en
    modo selección (lo controlamos pasando `onSwipeDelete: null`).
  - **Fix**: el check de selección se renderiza ahora como `Icon(Icons.check_circle)`
  inline a la izquierda del título (mismo tamaño visual que los otros meta-íconos),
  empujando el texto a la derecha cuando entra/sale de selección. Antes era un
  círculo negro absoluto encima de la esquina top-left.
- **Filtros aplicados**: solo notas visibles / filtradas (no a la DB
  completa); respeta los chips de Carpeta / Color / Fijadas y los
  filtros de búsqueda.
- **Tests**: 9 casos nuevos en `test/notes_selection_test.dart`
  (estado inicial, enter, enterWith, toggle bidireccional, selectAll,
  clearKeepingMode, exit, toggle-off-last, no-op empty selectAll).
  Total: **52 tests pasan**, `flutter analyze` sin issues.

### Sesión 2026-10-19 — Fase 4 (cierre): copia de seguridad ZIP desde Ajustes
- **Pedido**: poder descargar toda la información de la app en un `.zip` con la
  misma organización visual que el usuario ve (carpeta → carpeta, notas sueltas → raíz).
- **`NoteZipExporter`** (`lib/features/notes/note_zip_exporter.dart`):
  - Construye `Archive` con `package:archive` 4.5.2
    (ahora declarada como dependencia directa en `pubspec.yaml`).
  - Layout: carpeta como directorio dentro del zip, nota suelta en la raíz.
  - Filename del archivo: mismo que `NoteExporter.exportFilename(..., .txt)`
    → `Título (id).txt` (con saneo de caracteres `\/:*?"<>|` y colapso de
    puntos al borde) — el id garantiza unicidad global incluso si dos
    carpetas tuvieran el mismo nombre.
  - `sanitizeFolderName`: trim, reemplazo de `\\/*?"<>|` → `_`, colapso de
    puntos al borde, fallback a `"carpeta"`, truncado a 80 chars.
  - Helpers: `buildArchive`, `encodeArchive`, `writeTempZip`, `share`,
    `timestampSlug` para el nombre del zip (`notethink-export-YYYY-MM-DD_HHMMSS.zip`).
- **Repos / DAO**: añadidos `NotesRepository.getAllActive()` y
  `FoldersRepository.getAll()` (one-shots, equivalente a los streams pero
  sin suscripción activa — más limpio para una exportación puntual).
- **`NoteFileSaver.saveBytes({filename, mimeType, bytes})`**: nuevo método
  genérico que envuelve la misma `MethodChannel('note_think/save_file')`
  con la que ya cuenta el `save()` individual. Reutiliza la misma
  permission flow (solo SDK<29) y rethrow de `SaveException`. El `save()`
  por-nota quedó refactorizado encima del genérico.
- **Android (`MainActivity.kt`)**: `ensureExtension` ahora reconoce
  `application/zip` → `.zip`.
- **UI (`settings_screen.dart`)**: nueva sección **Datos** con la tile
  **"Descargar copia (.zip)"** → confirma → muestra modal de progreso
  ("Generando ZIP…") → guarda en `Downloads/NoteThink/` o, en plataformas
  donde `NoteFileSaver.isAvailable == false`, cae al share sheet con el
  mismo zip. Snackbars de éxito/error matcheando el patrón del export individual.
- **Filtros aplicados a la copia**: solo notas activas, no privadas, no en
  papelera (mismo corte que `watchActive()` + `getAllActive()`). Las
  carpetas que en realidad son tags (`isTag == true`) no se tratan como
  carpeta dentro del zip — el exporter las ignora al construir el map.
- **Tests** (`test/note_zip_exporter_test.dart`): 13 casos nuevos que
  cubren el saneo de carpetas (caracteres ilegales, puntos al borde,
  vacío, longitud), la decisión root vs carpeta del `archivePathForNote`
  (sin folder, con folder, con folder no resuelto, con folder vacío,
  con título con caracteres ilegales, ignorando tags), el round-trip
  build→encode→decode con `ZipDecoder` validando magic bytes + paths y
  el contenido (título + cuerpo), y el `timestampSlug`. Total: 43 tests
  pasan, `flutter analyze` sin issues, `flutter pub get` OK.

### Sesión 2026-10-15 — Fase 4: export individual + PDF + guardar en Descargas
- **Markdown / Texto plano** vía share sheet (suscinto original)
- **PDF** con imágenes embebidas vía share sheet:
  - Nuevo `NoteExportFormat.pdf` + `NoteExporter.toPdf(note)` usando
    el paquete `pdf` 3.13.1.
  - Render A4 con márgenes 48pt. Soporta: título H1, headers H1–H6,
    listas (bullet, ordered, checked `- [x]`, unchecked `- [ ]`),
    blockquote (border izquierdo + cursiva), code-block (fondo gris
    + monospace), inline rich text (bold, italic, strike, underline,
    code inline, link azul subrayado).
  - **Imágenes embebidas**: lee el archivo del path absoluto guardado
    en `note_images/` (`File.readAsBytes()` → `pw.MemoryImage`) y
    las inserta en línea con `BoxFit.contain`, altura 220pt. Las que
    no se pueden leer se omiten silenciosamente.
- **Guardar en Descargas** (nuevo, además de Compartir):
  - `NoteFileSaver` + MethodChannel `note_think/save_file` →
    `MainActivity.kt`.
  - Lado Kotlin: API 29+ usa `MediaStore.Downloads` con subcarpeta
    `Downloads/NoteThink/` (sin permisos, scoped storage). API ≤28
    escribe directo a `getExternalStoragePublicDirectory(DOWNLOADS)/NoteThink/`.
  - Lado Dart: pide `Permission.storage` solo si `device_info_plus`
    reporta SDK < 29 (en 29+ es no-op). Lanza `SaveException` si
    se deniega.
  - Manifest: `<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="28" />`.
- Flujo de UI ahora son **2 sheets**:
  1. Formato: Markdown / Texto plano / PDF
  2. Acción: Compartir / Guardar en Descargas (este último solo en
     Android)
- Snackbars de error específicos: "La nota no tiene contenido para
  exportar/guardar", "Se necesita permiso de almacenamiento…",
  "No se pudo guardar: <error>". Cuando guarda OK, snackbar
  "Guardado en Descargas/<nombre>".
- `build.gradle.kts`: `compileSdk = 37` (requerido por
  `permission_handler_android`).
- Dependencias añadidas: `pdf: ^3.13.1`, `permission_handler`,
  `device_info_plus` (transitiva).
- Tests: 3 casos nuevos para `toPdf` (PDF válido, vacío,
  header `%PDF-`). Total: 16 tests pasan, `flutter analyze` sin
  issues, APK debug compila.

### Extras (ideas diferidas, no en roadmap activo)
- ~~Recordatorios locales~~ (movido desde Fase 3 el 2026-10-15).
  **Fix de manifest aplicado 2026-10-16**: ahora el `AndroidManifest.xml`
  declara los dos `<receiver>` del plugin (`ScheduledNotificationReceiver`
  + `ScheduledNotificationBootReceiver`), por lo que la alarma del
  AlarmManager se atiende y los recordatorios se disparan. Queda
  pendiente re-evaluar el `androidScheduleMode` (probablemente
  `exactAllowWhileIdle` + pedir `SCHEDULE_EXACT_ALARM` desde
  Ajustes del sistema si la imprecisión Doze resulta molesta).
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

### Fase 2 — Swipe a papelera en vista de lista (2026-10-16)
- `_NotesList` envuelve cada `NoteCard` en un `Dismissible` con
  `direction: DismissDirection.endToStart` (solo derecha → izquierda).
  El grid queda intacto.
- `secondaryBackground`: fondo rojo tenue (`colorScheme.error` @ 0.15)
  con `Icon.delete_outline` + label "Mover a papelera" alineados a la
  derecha, mismo estilo que el swipe de la papelera.
- `confirmDismiss`: reusa `showConfirmDialog` con el mismo copy del
  options sheet ("¿Mover a papelera? Podrás restaurarla durante 30
  días…", botón "Mover"). Si cancela → la card vuelve a su sitio.
- `onDismissed`: `softDelete` + `RemindersService.cancel` si la nota
  tenía recordatorio (idéntico al path del options sheet). Spotify
  links se conservan porque la nota es recuperable.
- El long-press → options sheet sigue existiendo; el swipe es un atajo.

### Fase 3 — Recordatorios locales (2026-10-14) — **MOVIDO A EXTRAS 2026-10-15**
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

**Por qué se movió a Extras (2026-10-15):** los recordatorios no se
disparan en el dispositivo. Causa raíz: el `AndroidManifest.xml`
declara los `<uses-permission>` (incluido `RECEIVE_BOOT_COMPLETED`)
pero **NO declara los `<receiver>` del plugin** que son los que
reciben la alarma del AlarmManager y muestran la notificación:
- `com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver`
- `com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver`
  con intent-filter de `BOOT_COMPLETED` / `MY_PACKAGE_REPLACED`.

El permiso sin el receiver no sirve de nada. Verificado contra el
`AndroidManifest.xml` del ejemplo oficial del plugin
(`flutter_local_notifications-22.3.2/example/android/app/src/main/AndroidManifest.xml`)
— esos dos receivers están en el ejemplo y faltan en note-think.

Causas secundarias que también juegan en contra:
- `androidScheduleMode: inexactAllowWhileIdle` es battery-optimization
  sensible (Doze retrasa inexactas 15-60+ min). Decisión previa de no
  pedir `SCHEDULE_EXACT_ALARM` documentada en PROGRESS, pero el
  problema del manifest es previo.
- `tz.setLocalLocation(tz.UTC)` como fallback en `init()` si
  `FlutterTimezone.getLocalTimezone()` falla — puede calcular el
  horario con offset incorrecto.
- `schedule()` traga el `catch (e)` con `debugPrint` solo en debug;
  en release el error se silencia.

El código se queda intacto, solo cambia la clasificación. Cuando se
quiera retomar, queda pendiente re-evaluar el `androidScheduleMode`
(probablemente `exactAllowWhileIdle` + pedir `SCHEDULE_EXACT_ALARM`
desde Ajustes del sistema) y el fallback de timezone. El fix de
manifest (los dos `<receiver>`) se aplicó el 2026-10-16 y debería
haber destrabado la entrega de la alarma.

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

1. **Extras / Follow-ups de Spotify** (cuando se quiera):
   - Preview de 30s para tracks (OAuth PKCE + Web API + audio SDK)
   - Búsqueda dentro de la app (reemplaza el "paste URL")

## Convenciones

- Código en inglés, UI en español
- Sin emojis en código (salvo que se pidan explícitamente)
- Riverpod para todo estado
- Auto-guardado siempre, sin botones "guardar"