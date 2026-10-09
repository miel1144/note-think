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
- Filtros rápidos (carpeta, tag, color, fijadas)
- Auto-guardado (sin botón "guardar")

### Fase 3 — Power user
- Compartir nota vía share sheet de Android
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
- Navegación: bottom nav (Notas / Categorías / Papelera), búsqueda y ajustes desde el AppBar
- Punto de calor opcional por nota (selector de 4 colores)

## Pendientes y bugs conocidos

### Lógica de carpetas y tags (prioridad alta)
Hoy Categorías solo permite crear, renombrar y borrar; no están conectadas a las notas.
- Asignar carpeta y tags a una nota desde el editor
- Relación nota -> carpeta (una) y nota -> tags (varias); definir si se guarda con `IsarLinks` o con ids
- Filtrar la lista de notas por carpeta o tag al tocarla en Categorías
- Al borrar una carpeta o tag, desasignarlo de las notas que lo usan
- Contador de notas por carpeta/tag
- Resolver si "Categorías" sigue unificando ambos conceptos o se separan en dos pestañas internas

### Otros pendientes de Fase 1
- Papelera: auto-borrado a los 30 días (hoy solo manual)
- Búsqueda: usar el índice de Isar en vez del filtro en memoria
- Mantener pulsado en una nota de la papelera no hace nada
- Verificar en dispositivo real el flujo completo (crear, editar, reabrir, imágenes)

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

1. Lógica de carpetas y tags (ver arriba)
2. Cerrar pendientes de Fase 1
3. Fase 2: pin ya existe; faltan filtros rápidos, vista lista/grid y ordenamiento

## Convenciones

- Código en inglés, UI en español
- Sin emojis en código (salvo que se pidan explícitamente)
- Riverpod para todo estado
- Auto-guardado siempre, sin botones "guardar"