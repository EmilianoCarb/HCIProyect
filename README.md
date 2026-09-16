# HCIProyect

Proyecto para la materia de Interacción Humano-Computadora (HCI).
Desarrollado en Godot 4 (GDScript).

## Descripción

Juego de exploración/acción en 2D: un personaje se mueve libremente por un escenario de ruinas cubiertas de musgo, pudiendo correr (sprint) y atacar. Ambas acciones consumen una barra de estamina compartida que se regenera con el tiempo. El objetivo es avanzar y recolectar objetos repartidos en el nivel.

## Evaluación — Requisitos de HCI

- Movimiento libre del personaje (correr, saltar, atacar) con gestión de un recurso (estamina).
- **2 entradas soportadas**: teclado/botones en pantalla (control discreto/binario) y gestos de trackpad (swipe de 2 dedos, control analógico — la intensidad del swipe determina qué tan fuerte es el sprint).
- **2 salidas soportadas**: visual (animaciones del personaje, fondo parallax y barra de estamina flotante) y auditiva (sonido al moverse y al chocar con los bordes de pantalla).
- **Comparación de experiencia de usuario entre input binario (teclado) vs. input analógico (trackpad)** para el mismo sistema de estamina y de velocidad — punto central de análisis de la materia. A diferencia del teclado (que salta directamente entre "caminar" y "correr"), el trackpad interpola la velocidad de forma continua según la intensidad del swipe, mostrando de forma tangible la diferencia entre un control binario y uno analógico.

## Estructura del proyecto
```
HCIProyect/
├── project.godot
├── scenes/
│ ├── main/ # main.tscn — escena principal
│ ├── player/ # Player.tscn
│ └── ui/ # botones UI, barra de estamina
├── scripts/
│ ├── Player.gd # movimiento, estamina, ataque, animaciones, input trackpad
│ └── PlayerCamera.gd # límites de cámara siguiendo al personaje
├── assets/
│ ├── sprites/
│ │ ├── hero/ # Ozzbit Games — idle, walk, run, jump, fall, combo_1, combo_1_end
│ │ ├── backgrounds/ # fondo cielo+planeta y ruinas musgosas (parallax)
│ │ ├── tileset/ # Mossy Tileset (plataformas, decoraciones, hazards)
│ │ ├── enemies/ # Slimes (Orange, Green)
│ │ └── plants/ # Plant Animations (decoración ambiental)
│ ├── audio/
│ │ ├── sfx/
│ │ └── music/
│ └── fonts/
└── docs/ # capturas, créditos, informe
```

## Cómo correr el proyecto

1. Abre Godot 4.x.
2. Importa la carpeta del proyecto (`project.godot`).
3. Ejecuta la escena `scenes/main/main.tscn`.

## Controles

**Teclado:**
- Flechas / `A` `D`: moverse izquierda/derecha.
- Flecha arriba / `W`: saltar.
- `Shift`: sprint (mantener presionado, consume estamina).
- Click izquierdo / tecla de ataque: atacar (consume estamina).

**Trackpad (swipe de 2 dedos, sin necesidad de click):**
- Swipe izquierda/derecha: moverse. La intensidad del swipe controla la velocidad de forma continua entre "caminar" y "correr"; por encima de un umbral entra en sprint real y empieza a consumir estamina.
- Swipe hacia arriba: saltar (se detecta por una racha corta de ticks de scroll consecutivos).
- El ataque **no** se soporta por gesto de trackpad puro (un tap sin movimiento no genera ningún evento detectable); usar click o el botón de UI.

> **Nota técnica:** Godot no recibe el swipe de 2 dedos como gesto nativo (`InputEventPanGesture`) de forma confiable en Linux ni Windows — el compositor del sistema lo traduce a eventos de rueda del mouse (`MOUSE_BUTTON_WHEEL_*`). El juego escucha esos eventos y acumula "ticks" para simular intensidad analógica. Además, la preferencia de sistema **"desplazamiento natural"** (Ajustes → Panel táctil) invierte el sentido de esos eventos; esto se compensa con la propiedad exportada `trackpad_natural_scroll` en `Player.gd`, que debe coincidir con la configuración del sistema operativo de quien pruebe el juego. Se documenta como limitación conocida y punto de análisis de HCI: es una preferencia de accesibilidad del SO que el juego no puede leer automáticamente.

**Botones en pantalla:** disponibles como alternativa táctil a los controles de arriba (mover, saltar, sprint, atacar).

## Mecánica

- El personaje se mueve libremente dentro de los límites de la pantalla.
- La estamina se gasta al hacer sprint (más rápido si el swipe del trackpad es más intenso) y al atacar; se regenera automáticamente tras un breve tiempo sin usarse.
- Una barra de estamina flotante aparece sobre el personaje solo cuando no está al 100%, y desaparece al regenerarse por completo.
- El ataque tiene una animación de golpe seguida de una de recuperación antes de poder moverse con normalidad de nuevo.
- El fondo usa dos capas `Parallax2D` (cielo con planeta + ruinas en primer plano) para dar sensación de profundidad.

## Créditos

- **Animaciones del personaje:** Ozzbit Games — [ozzbit-games.itch.io](https://ozzbit-games.itch.io) (versión gratuita, uso no comercial, créditos requeridos).
- **Fondo (cielo + planeta):** generado proceduralmente para este proyecto, inspirado en la paleta de assets de referencia tipo Deep-Fold.
- **Tileset de ruinas musgosas:** Mossy Tileset — [maaot.itch.io/mossy-cavern](https://maaot.itch.io/mossy-cavern).
- **Enemigos (slimes):** Slimes (Orange, Green) — *pendiente confirmar autor/licencia exacta antes de la entrega.*
- **Plantas decorativas:** Plant Animations — *pendiente confirmar autor/licencia exacta antes de la entrega.*
- **Assets adicionales de referencia:** anokolisa — [Moon Graveyard](https://anokolisa.itch.io/moon-graveyard), [Sidescroller Pixelart Forest 16x16](https://anokolisa.itch.io/sidescroller-pixelart-sprites-asset-pack-forest-16x16).

> ⚠️ Antes de la entrega final, completar este apartado con el autor y tipo de licencia exacto de cada asset usado (Slimes, Plant Animations, y cualquier otro pack sumado), siguiendo el mismo formato que Ozzbit Games. Revisar especialmente si alguno requiere atribución obligatoria o restringe uso comercial/educativo.

## Roadmap del semestre

- [x] Movimiento libre con teclado
- [x] Gravedad y salto
- [x] Sistema de estamina (sprint + ataque)
- [x] Animaciones del personaje (idle, walk, run, jump, fall, attack)
- [x] Input por trackpad (swipe analógico vía scroll wheel)
- [x] Barra de estamina flotante en UI
- [x] Fondo con parallax (cielo/planeta + ruinas musgosas)
- [ ] Objetos recolectables en el nivel
- [ ] Enemigos básicos (slimes) con colisión/daño
- [ ] Escenario/nivel más allá de una sola pantalla (tileset de ruinas + cámara con límites)
- [ ] Sonido adicional (ataque, recolección)
- [ ] Pruebas de usuario (HCI) comparando teclado vs. trackpad

## About

Sin descripción, sitio web, ni topics.
