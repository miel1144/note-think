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

## Próximos pasos

Empezar **Fase 1**:
1. `flutter create` con bundle id para Android
2. Agregar dependencias al `pubspec.yaml`
3. Definir `AppTheme` (light + dark con paletas arriba)
4. Crear widgets base neumórficos (`NeuCard`, `NeuButton`, `NeuInput`)
5. Modelos Isar (`Note`, `Folder`, `Tag`)
6. Pantallas: lista de notas, editor, papelera

## Convenciones

- Código en inglés, UI en español
- Sin emojis en código (salvo que se pidan explícitamente)
- Riverpod para todo estado
- Auto-guardado siempre, sin botones "guardar"