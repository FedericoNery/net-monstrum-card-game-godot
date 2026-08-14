# Implementación en Godot — Minijuego de cartas

Este documento conecta las reglas de negocio definidas en [REGLAS_DE_NEGOCIO.md](REGLAS_DE_NEGOCIO.md) con el estado real del código Godot. No repite el detalle de arquitectura general, autoload o deuda técnica que ya está en [SPEC.md](SPEC.md) — lo referencia en lugar de duplicarlo.

## 1. Propósito

Para cada regla de negocio del minijuego, indicar si hoy tiene soporte en el código, parcial o nulo, y proponer (a nivel conceptual, sin implementar todavía) cómo cerrar los huecos que existan.

## 2. Tabla de cobertura: regla de negocio → estado actual

| Regla de negocio | Estado | Detalle |
|---|---|---|
| Tipos de carta (Digimon / Programación) | 🟡 Parcial | Modelado en `domain/card_digimon.gd`, `domain/card_equipment.gd`, `domain/card_energy.gd`, `domain/card_summon_digimon.gd`, `domain/card_programming.gd`. El modelo de dominio ya es **más granular** que las 2 categorías de negocio: separa Equipment, Energy y SummonDigimon como subclases propias en vez de tratarlas como una única "carta de Programación" con distintos efectos. Esto es una decisión de implementación, no una regla de negocio distinta — se puede mantener así, ya que facilita tipar cada efecto. |
| AP / HP | 🟡 Parcial | `CardDigimon.attackPoints` / `CardDigimon.healthPoints` existen como datos (`domain/card_digimon.gd:4-5`), pero no hay ninguna lógica de batalla que los compare, reste HP, o mande una carta a la basura. |
| Carpetas (40 cartas, máx. 4 iguales) | 🔴 No implementado | No existe ninguna clase `Deck`/`Folder`. `player_hand.gd` hoy instancia siempre **6 copias fijas** de `card.tscn` en `_ready()` (`HAND_COUNT = 6`, `player_hand.gd:3,13-16`), sin relación con ninguna carpeta ni validación de cantidades. |
| Fases de batalla (Start/Draw/Load/Summon/Compile/Battle) | 🔴 No implementado | No hay máquina de turnos ni de fases en ningún script del proyecto. |
| S-Energy | 🔴 No implementado | `DB.COLORS_CARD` (en `cards_database.gd`) existe como enum de colores y se usa para tipar cartas, pero no hay ningún contador de energía por jugador, ni lógica que la incremente en un "Draw Phase" o la descuente al invocar. |
| Combos (3+/4+ copias en campo) | 🔴 No implementado | `digimon_field.gd` es un stub (`var digimon_field = []`, dos métodos vacíos) — no hay noción de "campo con cartas" todavía, así que tampoco puede haber lógica de combos. |
| Progreso / tienda / monedas | 🔴 No implementado | No existe ningún sistema de economía, monedas ni tienda en el proyecto. |
| Hover / selección / animación de mano / flip visual | 🟢 Implementado | Ver `SPEC.md` secciones 6 y 7. Es presentación visual de una carta individual, no lógica de reglas de la partida — por eso no aparece como cobertura de ninguna regla de negocio de esta tabla. |

**Bloqueante transversal**: `card.gd` tiene `CardInformation` fijado siempre a `CARDS_DATA[0]` (documentado en `SPEC.md` sección 6 y 8). Mientras esto no se corrija, **ninguna carta instanciada puede mostrar datos distintos entre sí**, lo cual bloquea de hecho cualquier sistema nuevo que dependa de tener cartas variadas en juego (carpetas, mano real, campo, combos). Es, en la práctica, el primer paso necesario antes de avanzar con cualquier punto de la sección 3.

## 3. Propuesta de diseño para los sistemas faltantes

Ideas a nivel conceptual, sin implementar en este trabajo. Todas asumen que ya se resolvió el bloqueante transversal de la sección 2.

### `EnergyTracker`

Lleva el conteo de S-Energy por jugador y color (los 6 colores de `DB.COLORS_CARD`). Se incrementa cuando se roba una carta de ese color en Draw Phase, y se descuenta cuando se invoca un Digimon en Summon Phase, según el costo de su `level` (tabla de la sección 5 de `REGLAS_DE_NEGOCIO.md`). Podría vivir como un autoload nuevo (similar a `CardsDatabase`) o como un nodo hijo de un futuro controlador de partida.

### `BattlePhaseManager` (o nombre similar)

Controla la secuencia Start → Draw → Load → Summon → Compile → Battle, alternando turnos entre los dos jugadores dentro de las fases que lo requieren (Load y Compile). Sería el punto central que orquesta cuándo se puede jugar qué tipo de carta.

### `Deck` / `Folder`

Nueva clase o `Resource` que agrupe hasta 40 referencias a cartas de `DB.CARDS_DATA`, con validación de máximo 4 copias de una misma carta. Reemplazaría el armado fijo de 6 cartas que hoy hace `player_hand.gd` (`player_hand.gd:3,13-16`) por un robo real desde una carpeta seleccionada.

### `ComboResolver`

Lógica que recorra las cartas presentes en el campo (una vez que `digimon_field.gd` deje de ser un stub), agrupe por identificador de carta, y aplique la sumatoria de AP/HP cuando haya 3 o más copias, más el bonus adicional cuando haya 4 o más (valor de bonus a definir, ver nota en `REGLAS_DE_NEGOCIO.md` sección 6).

### Reutilización de lo existente

- `DB` (`cards_database.gd`, autoload) debería ser la **única** fuente de datos de cartas para todos estos sistemas nuevos — hoy `card.gd` no la usa, sino una copia local duplicada (ver `SPEC.md` sección 8).
- Los tipos de `domain/*.gd` (`CardDigimon`, `CardEquipment`, `CardEnergy`, `CardSummonDigimon`) ya sirven como DTOs razonables para `EnergyTracker`, `Deck` y `ComboResolver` — no haría falta crear nuevas estructuras de datos, solo lógica que las consuma.

## 4. Orden sugerido de implementación

1. Corregir el hardcode de `CardInformation = CARDS_DATA[0]` en `card.gd` (prerequisito de todo lo demás).
2. `EnergyTracker`.
3. `Deck` / `Folder`.
4. `BattlePhaseManager`.
5. `ComboResolver`.
6. Economía / tienda (menor prioridad — es progresión posterior a la batalla, no parte del núcleo del minijuego).
