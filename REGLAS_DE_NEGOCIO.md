# Reglas de negocio — Minijuego de cartas

Documento de diseño de juego. Describe las reglas del **minijuego de cartas** en el que se basa este proyecto, independientemente de cómo esté (o no esté todavía) implementado en Godot. Para el mapeo contra el código actual, ver [IMPLEMENTACION_GODOT.md](IMPLEMENTACION_GODOT.md).

## 1. Introducción

Este proyecto recrea el minijuego de batallas de cartas que existe dentro de **Digimon World 2003** (PS1). El foco es exclusivamente ese minijuego interno — no se busca recrear el RPG completo (exploración del mundo, sidequests, progresión de personaje, etc.), salvo en la medida en que ese contexto explica de dónde salen recompensas como monedas o sobres de cartas (sección 8).

## 2. Tipos de carta

Existen dos grandes familias de cartas:

### Cartas de Digimon

Representan un Digimon invocable al campo de batalla. Tienen dos valores:

- **AP** (Attack Points / puntos de ataque)
- **HP** (Health Points / puntos de vida)

Notación: `60/55` significa 60 de AP y 55 de HP. Cuando el HP de un Digimon llega a 0, esa carta va a la **basura (trash)**.

### Cartas de Programación

Aplican distintos efectos posibles en vez de ocupar un lugar en el campo. Del listado de cartas del material recolectado se desprenden estas categorías funcionales (no son tipos de carta separados a nivel de reglas, sino usos distintos de la misma familia "Programación"):

- **Energía**: otorgan S-Energy de un color al jugador (ej. "White Power" +1 blanca, "Green Force" +2 verdes) o se la restan al rival (ej. "White Remove", "Black Remove", -2 de ese color).
- **Refuerzo / debilitamiento**: modifican AP y/o HP de uno o varios Digimon, propios o rivales (ej. "Gold Aura" +10 AP/HP a todos los Digimon, "Protect Armor" +10 HP a uno, "Berserk Energy" +10 AP y -10 HP a uno).
- **Daño**: restan HP directamente a uno o varios Digimon rivales, sin que medie un ataque en Battle Phase (ej. "Fire Cannon" 30 de daño a un Digimon rival, "Flame Gatlin" 15 de daño a todos los Digimon en juego).
- **Invocación directa**: traen uno o más Digimon específicos al campo sin pasar por la Summon Phase normal (ej. "Summon Angemon" trae 2 Angemon al campo, "Scramble Up" trae un Digimon desde la mano al campo).
- **Destrucción / remoción de campo**: mandan Digimon a la basura o de vuelta a la mano, propios o rivales, a veces condicionado por color (ej. "Delete Matrix" manda todos los Digimon del campo a la basura, "Eclipse Undo" devuelve un Digimon rival a su mano).
- **Robo y búsqueda**: hacen robar cartas del propio mazo, elegir una carta puntual del mazo, o recuperar una carta de la propia basura (ej. "Charge Terminal" roba 2 cartas del mazo, "Digimon Charge" busca una carta de Digimon específica en el mazo, "Ecoly Cycle" recupera una carta de la basura).
- **Disrupción de mano/mazo rival**: fuerzan al rival a descartar cartas de su mano, o destruyen cartas directamente de su mazo (ej. "Vicious Hacking" descarta una carta de la mano rival, "Illegal Access" manda 2 cartas del mazo rival a la basura).
- **Control**: toman el control de un Digimon del rival por el resto de la partida (ej. "Control Parts").
- **Cancelación / contraataque**: permiten mandar a la basura una carta de Programación que el rival (o uno mismo) acaba de jugar, **antes** de que su efecto llegue a aplicarse (ej. "Freeze Bug", "Cancel Wheel"). Son las cartas clave de la mecánica de resolución en cadena — ver sección 5.

## 3. Carpetas (mazos)

- Antes de poder batallar, el jugador arma una **carpeta** de exactamente **40 cartas**.
- Se pueden incluir hasta **4 copias** de una misma carta en una carpeta.
- Antes de cada batalla, el jugador selecciona qué carpeta va a usar como mazo.

## 4. Fases de la batalla

Una batalla se gana ganando **2 de 3 rondas**. Cada ronda se compone de 6 fases, en este orden:

1. **Start Phase** — se determina quién empieza la ronda.
2. **Draw Phase** — ambos jugadores roban 6 cartas de su carpeta a la mano. Si un jugador no puede robar 6 cartas (se quedó sin mazo), pierde la batalla. Durante la batalla, la mano tiene un máximo de 10 cartas.
3. **Load Phase** — los jugadores pueden jugar cartas de programación (con restricciones: no todas las cartas de programación están permitidas en esta fase). Los turnos se alternan hasta que ambos jugadores deciden pasar.
4. **Summon Phase** — se invocan Digimon al campo, siempre que se disponga de la S-Energy necesaria (ver sección 6).
5. **Compile Phase** — igual que Load Phase (turnos alternados hasta que ambos pasen), pero acá sí se puede jugar cualquier carta de programación sin restricción.
6. **Battle Phase** — los Digimon del campo se enfrentan. Se compara AP contra HP: el/los Digimon que llegan a 0 HP van a la basura. Gana la ronda quien deja al rival sin Digimon o con menos recursos en el campo. Si ambos jugadores quedan en 0 al mismo tiempo, **pierde el jugador retador** de la batalla.

## 5. Mecánica de resolución de cartas de programación

Esta sección detalla cómo se juegan las cartas de Programación dentro de la Load Phase y la Compile Phase (punto 3 y 5 de la sección anterior). No es una fase nueva, sino el mecanismo interno de esas dos fases.

### Turnos alternados, una carta a la vez

Dentro de Load Phase o Compile Phase, los jugadores **no** juegan todas sus cartas de Programación de una sola vez. Se turnan: un jugador juega **una única** carta de Programación (o pasa su turno si no quiere/no puede jugar ninguna), y el turno pasa al rival. Esto se repite hasta que **ambos jugadores pasan de forma consecutiva** — recién ahí termina la fase.

### Ventana de reacción

Cuando un jugador juega una carta de Programación, esa carta **no se resuelve de inmediato**: primero se le da al rival la oportunidad de reaccionar jugando él también una carta de Programación (típicamente una carta de cancelación) antes de que la primera aplique su efecto.

- Si el rival **pasa** (no reacciona), la carta jugada se resuelve normalmente y aplica su efecto.
- Si el rival juega una **carta de cancelación** (ej. "Freeze Bug" — *"Put a drawn PG card to trash"*, o "Cancel Wheel" para cartas de color marrón), la carta original se manda a la basura **antes** de poder resolverse: nunca llega a aplicar su efecto.

### Cadenas de desactivación

Una carta de cancelación puede, a su vez, ser cancelada por otra carta de cancelación del rival, formando una cadena. Ejemplo:

1. Jugador A juega **Delete Matrix** (manda todos los Digimon del campo a la basura).
2. Jugador B responde con **Freeze Bug**, intentando trashear Delete Matrix antes de que se resuelva.
3. Jugador A responde a su vez con su propio **Freeze Bug**, intentando trashear el Freeze Bug de Jugador B.
4. Jugador B pasa (no tiene más reacciones).
5. La cadena se resuelve **en orden inverso al que se jugó** (la última carta jugada es la primera en resolverse): primero se resuelve el Freeze Bug de A, que trashea el Freeze Bug de B antes de que este llegue a resolverse. Como el Freeze Bug de B nunca se resolvió, no llegó a cancelar nada — así que Delete Matrix de A sí se resuelve normalmente y aplica su efecto.

La fase (Load o Compile) recién termina cuando, tras resolverse toda la cadena pendiente, ambos jugadores vuelven a pasar de forma consecutiva sin jugar ni reaccionar con nada más.

> **Nota**: el material fuente no detalla explícitamente todas las reglas de esta mecánica (por ejemplo, si hay cartas inmunes a cancelación, o un límite de cartas por cadena). Lo descrito acá es la interpretación adoptada para este proyecto, basada en el comportamiento documentado de "Freeze Bug"/"Cancel Wheel" y en la aclaración explícita de que la resolución es por turnos, una carta a la vez, permitiendo cadenas.

## 6. S-Energy

Existen 6 colores de energía: **blanco, azul, verde, rojo, negro y marrón**.

- La S-Energy de un color aumenta en 1 cada vez que se roba una carta de ese color durante la Draw Phase.
- La S-Energy se gasta al invocar un Digimon, según su nivel:

| Nivel de Digimon | Costo en S-Energy |
|---|---|
| Baby | 0 (gratis) |
| Rookie | 1 |
| Champion | 2 |
| Ultimate | 3 |
| Mega | 4 |

> **Nota sobre esta tabla**: el material fuente en inglés (la guía original de Digimon World 2003 y una FAQ de Digimon World 3 incluida junto con el resto del material) describe los costos como Rookie = gratis, Champion = 1, Ultimate = 2, Mega = 3, sin mencionar el nivel Baby. La tabla de arriba corresponde a la versión ya adaptada en español para este proyecto (que sí incluye Baby y corre los demás niveles un paso), y se tomó como la canónica por ser la pensada específicamente para este juego. **Confirmar que esta es la tabla que se quiere usar** antes de tomarla como definitiva para el diseño.

## 7. Combos

Un **combo** ocurre cuando hay **3 o más copias de la misma carta** en el campo de batalla:

- El AP y el HP de todas las copias se suman entre sí.
- Si hay **4 o más copias**, se aplica un bonus adicional a esa suma.

> El material fuente no especifica el valor exacto de ese bonus — queda pendiente de definir.

## 8. Progreso y economía

- Ganar una batalla otorga **monedas**.
- Las monedas se pueden gastar en la **tienda interna** del juego para comprar sobres de cartas o cartas puntuales que estén en oferta.
- En el juego original, también se obtienen sobres de cartas ("expansiones") al vencer a personajes dentro del RPG — se menciona solo como contexto de dónde proviene esta progresión, sin entrar en el detalle del RPG (fuera del alcance de este documento).

## 9. Glosario

| Término | Significado |
|---|---|
| **AP** | Attack Points — puntos de ataque de una carta Digimon. |
| **HP** | Health Points — puntos de vida de una carta Digimon; en 0, la carta va a la basura. |
| **S-Energy** | Recurso de 6 colores necesario para invocar Digimon de nivel Rookie o superior. |
| **Carpeta** | Mazo de 40 cartas (máx. 4 copias de una misma carta) que se elige antes de batallar. |
| **Combo** | 3 o más copias de la misma carta en el campo; suman AP/HP y dan bonus con 4+. |
| **Cadena** | Secuencia de cartas de Programación jugadas en respuesta unas de otras (típicamente cartas de cancelación) durante Load o Compile Phase; se resuelve en orden inverso al jugado. |
| **Trash** | Zona de descarte donde van las cartas Digimon con 0 HP y otras cartas usadas/descartadas. |
| **Sobre / Booster** | Paquete de cartas que se obtiene como recompensa o se compra en la tienda. |
