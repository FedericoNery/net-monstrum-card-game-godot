# SPEC — tcgexample

Documento de referencia técnica del proyecto. Describe el estado actual del código, no un tutorial de uso.

Documentos relacionados: [REGLAS_DE_NEGOCIO.md](REGLAS_DE_NEGOCIO.md) (diseño del minijuego de cartas) e [IMPLEMENTACION_GODOT.md](IMPLEMENTACION_GODOT.md) (cómo esas reglas se mapean o se propone que se mapeen sobre este código).

## 1. Propósito del proyecto

Prototipo de un juego de cartas coleccionables (TCG) estilo Digimon, hecho en **Godot 4.5**. El desarrollo está enfocado hoy en el modelo de datos de las cartas y su representación visual (una carta individual, la mano del jugador). Todavía no existe un loop de juego, turnos, ni reglas de combate implementadas.

## 2. Configuración del proyecto (`project.godot`)

- **Autoload único**: `CardsDatabase` → `res://cards_database.gd`. Como ese script declara `class_name DB`, en todo el proyecto se lo referencia globalmente como `DB` (por ejemplo `DB.CARD_TYPE.DIGIMON`), no como `CardsDatabase`.
- **Escena principal**: `main.tscn` (`run/main_scene`).
- **Viewport**: 1920x1080.
- **Renderer**: `gl_compatibility` (features `"4.5"`, `"GL Compatibility"`).
- No hay input map personalizado ni plugins/addons configurados.

## 3. Arquitectura de escenas

Árbol de `main.tscn`:

```
Main (Node2D)
├── Card            → instancia de scenes/card.tscn
├── CardBack        → instancia de scenes/card_back.tscn (oculta)
├── PlayerHand      → instancia de scenes/player_hand.tscn
├── DigimonField    → instancia de scenes/digimon_field.tscn
│                     (con scenes/digimon_field.gd reasignado directamente
│                      sobre la instancia, no heredado de la escena base)
└── Node2D          → nodo vacío, oculto (placeholder sin uso claro)
```

Nota: `main.tscn` tiene actualmente cambios sin commitear (toggles de visibilidad en `PlayerHand` y `DigimonField`). Este documento describe el árbol tal como está en disco en este momento, no necesariamente su estado final.

## 4. Modelo de dominio de cartas (`domain/*.gd`)

Jerarquía de clases (GDScript puro, sin escena asociada):

- **`Card`** (`domain/card.gd`, base) — `id`, `price`, `name`, `type: DB.CARD_TYPE`.
- **`CardDigimon`** (`domain/card_digimon.gd`) — agrega `color`, `attackPoints`, `healthPoints`, `energyCount`, `evolution`, `level`.
- **`CardEquipment`** (`domain/card_equipment.gd`) — agrega `attackPoints`, `healthPoints`, `targetScope` (`UNIQUE`/`PARTIAL`/`ALL`), `quantityOfTargets`.
- **`CardEnergy`** (`domain/card_energy.gd`) — agrega `color`, `energyCount` (puede ser negativo).
- **`CardSummonDigimon`** (`domain/card_summon_digimon.gd`) — agrega `digimonsCards` (array de diccionarios crudos).
- **`CardProgramming`** (`domain/card_programming.gd`) — stub vacío, sin campos propios.

Importante: los enums que **realmente se usan** en todo el proyecto son los internos de `cards_database.gd` (`DB.CARD_TYPE`, `DB.COLORS_CARD`), no los archivos sueltos `domain/card_type.gd` (`class_name CARD_TYPE`) ni `domain/colors.gd` (`class_name COLORS_CARD`) — ver sección 8.

## 5. Base de datos de cartas (`cards_database.gd` / autoload `DB`)

- `DB.CARDS_DATA`: array de ~150 instancias de `CardDigimon` / `CardEquipment` / `CardEnergy` / `CardSummonDigimon`, construidas a mano a partir de diccionarios literales dentro del script (no hay archivos `.tres`, JSON, ni recursos exportados — todo vive como código).
- `DB.COLORS_STRING` y `DB.CARD_TYPE_STRING`: diccionarios enum → string pensados para mostrar nombres legibles. Verificado por búsqueda en todo el proyecto: **no tienen ningún uso actual** fuera de su propia definición.

## 6. Flujo de datos: de la base de datos al render

El recorrido real (no el ideal) es el siguiente:

1. `scenes/card.tscn` tiene asignado el script `card.gd`.
2. `card.gd` **no lee `DB.CARDS_DATA`**. En cambio, contiene una copia local casi idéntica de la base de datos completa (líneas 1 a 2039 del archivo, ~2000 líneas duplicadas de `cards_database.gd`).
3. Esa copia local se usa solo para una cosa: `card.gd:2045` define `var CardInformation: CardDigimon = CARDS_DATA[0]` — **siempre el índice 0** (Agumon), fijo, sin ningún parámetro ni setter para elegir otra carta.
4. En `_ready()`, con ese `CardInformation` fijo: se arma la ruta `res://digimon-images/<name>.jpg` y se carga en `$Panel/CardImage`, se completan los `RichTextLabel` de `Name` y `Atk` (formato `"{atk}/{hp}"`), se colorea el borde del panel según `CardInformation.color` (solo hay ramas implementadas para `RED` y `BLUE`; `GREEN`/`WHITE`/`BLACK`/`BROWN` no tienen tratamiento), y se dispara la animación `card_flip`.

**Consecuencia directa**: no importa cuántas veces se instancie `card.tscn` ni qué se intente pasarle desde afuera — hoy **siempre se ve la misma carta (Agumon)**. Esta es una limitación conocida y aceptada, no corregida en este documento ni en el trabajo que lo acompaña.

## 7. Funcionalidad implementada actualmente

- **Hover**: `Area2D.mouse_entered` / `mouse_exited` → `highlight_card(bool)`, que escala el nodo completo de la carta a `1.05` al pasar el mouse y vuelve a `1.0` al salir.
- **Selección por click**: `Area2D.input_event` → `_on_area_2d_input_event()`. Alterna `isSelected`; si se selecciona, cambia el borde del panel a `Color.GOLD` (solo implementado para el color `RED` por ahora) y desplaza la carta 50px hacia arriba (`moveUp()`); al deseleccionar, vuelve al color original y baja 50px (`moveDown()`).
- **Animación de la mano** (`player_hand.gd`): en `_ready()` instancia 6 copias de `card.tscn`, las agrega como hijas, y calcula sus posiciones en abanico centrado horizontalmente (usa `get_viewport().size.x`, por lo que no depende de estar bajo `Main` — funciona igual si la escena se corre sola). El movimiento a la posición final se anima con un `Tween` de 0.3s.
- **Flip de carta**: `AnimationPlayer` con la animación `"card_flip"` (0.7s), que anima el `scale` de `Panel` y `CardBackImage` para simular que la carta se da vuelta. Se dispara automáticamente en `_ready()` de cada carta.

## 8. Limitaciones conocidas y deuda técnica

- **`CardInformation = CARDS_DATA[0]` hardcodeado** en `card.gd:2045` — impide mostrar cartas distintas de Agumon. Decisión consciente: documentado acá, no corregido en este trabajo.
- **Base de datos duplicada**: `card.gd` contiene ~2039 líneas que reproducen casi al detalle `cards_database.gd`, pero solo se usa el índice 0 de esa copia local. Es redundancia total; el arreglo natural del punto anterior probablemente implique borrar esta copia y leer de `DB.CARDS_DATA` en su lugar.
- **`domain/card_type.gd` y `domain/colors.gd` son código muerto** (confirmado por búsqueda en todo el proyecto): ningún archivo usa esos `class_name` globales (`CARD_TYPE`, `COLORS_CARD`); todo el código usa los enums internos `DB.CARD_TYPE` / `DB.COLORS_CARD` definidos dentro de `cards_database.gd`.
- **`DB.COLORS_STRING` / `DB.CARD_TYPE_STRING` sin uso** confirmado en el resto del proyecto (ver sección 5).
- **`CardSummonDigimon._init` no llama a `super._init(card_data)`**: las cartas de este tipo en `DB.CARDS_DATA` (ej. "Summon Gatomon x2") quedan con `id`, `price`, `name` y `type` sin inicializar (valores por defecto).
- **`CardProgramming._init` es un stub vacío** que ignora `card_data` por completo.
- **Entradas duplicadas confirmadas en `DB.CARDS_DATA`**: varios `_id` se repiten (algunos hasta 4 veces), tanto en cartas Digimon como de Energía.
- **`digimon_field.gd` / `scenes/digimon_field.tscn` son un stub**: `var digimon_field = []` y dos métodos (`activate_program_card()`, `summon_digimon_to_field()`) vacíos (`pass`). La escena no tiene nodos hijos ni representación visual.
- **No hay framework de testing automatizado** (ni GUT ni otro) instalado en el proyecto. Cualquier verificación hoy es manual, vía escena + ejecución en el editor (ver sección 10).

## 9. Próximos pasos sugeridos

No implementados en este trabajo, quedan como backlog:

1. Corregir el hardcode de `card.gd:2045` para que cada `Card` reciba desde afuera qué carta mostrar (por ejemplo, un método `set_card_data(card: Card)` llamado antes de o durante `_ready()`).
2. Eliminar la base de datos duplicada de `card.gd` y hacer que lea de `DB.CARDS_DATA` (autoload).
3. Eliminar `domain/card_type.gd` y `domain/colors.gd` si se confirma que no se necesita esa capa separada de `DB`.
4. Corregir `CardSummonDigimon._init` y `CardProgramming._init` para que llamen a `super._init(card_data)`.
5. Deduplicar las entradas repetidas de `DB.CARDS_DATA`.
6. Implementar `digimon_field.gd` (colocación de Digimon en el campo, lógica real detrás de `activate_program_card()` / `summon_digimon_to_field()`).
7. Evaluar incorporar un framework de testing (ej. GUT) si el proyecto crece en complejidad.

## 10. Cómo probar secciones del juego por separado (sin programar)

Godot permite ejecutar **cualquier escena abierta en el editor** de forma aislada, sin cambiar cuál es la escena principal del proyecto (`main.tscn`). Esto es útil para revisar una sección puntual sin tener que correr todo el juego.

Para eso existen tres escenas de prueba en `scenes/tests/`:

- **`test_card.tscn`** — muestra una sola carta (permite probar hover, click/selección y la animación de flip). Por la limitación de la sección 8, siempre va a mostrar Agumon.
- **`test_player_hand.tscn`** — muestra la mano completa de 6 cartas en abanico, igual que en `main.tscn` pero sola.
- **`test_digimon_field.tscn`** — instancia el campo de Digimon. Hoy solo va a mostrarse un texto de aviso, porque `digimon_field.gd` todavía es un stub sin contenido visual (ver sección 8); la escena queda preparada para cuando se implemente.

**Pasos para correr una de estas escenas:**

1. Abrir el proyecto en Godot 4.5.
2. En el panel **FileSystem** (normalmente visible abajo a la izquierda del editor), navegar a la carpeta `scenes/tests/`.
3. Hacer **doble click** sobre el archivo que se quiera probar (por ejemplo `test_card.tscn`). Se abre en una pestaña nueva del editor, sin afectar `main.tscn`.
4. Con esa pestaña activa (en foco), presionar **F6** — o el botón de "play" con forma de claqueta arriba a la derecha del editor, que es distinto del botón de play normal (ese corre siempre `main.tscn`). Se abre una ventana nueva ejecutando **únicamente** esa escena.
5. Para terminar la prueba, cerrar esa ventana o presionar el botón de Stop en Godot.
6. Para probar otra sección, repetir desde el paso 3 con otro archivo.

**Ojo**: F6 ejecuta la pestaña que está activa en ese momento. Si por error queda en foco la pestaña de `main.tscn`, F6 va a correr el juego completo en lugar de la escena de prueba — conviene fijarse en el título de la pestaña antes de presionar la tecla.
