# HCIProyect

Proyecto para la materia de Interacción Humano-Computadora (HCI).
Desarrollado en Godot 4 (GDScript).

## Descripción

Juego de exploración/acción en 2D: un personaje se mueve libremente por el escenario, pudiendo correr (sprint) y atacar. Ambas acciones consumen una barra de estamina compartida que se regenera con el tiempo. El objetivo es avanzar y recolectar objetos repartidos en el nivel.

## Evaluación — Requisitos de HCI

- Movimiento libre del personaje (correr, saltar, atacar) con gestión de un recurso (estamina).
- **2 entradas soportadas**: teclado/botones en pantalla (control discreto/binario) y gestos de trackpad (swipe de 2 dedos, control analógico — la intensidad del swipe determina qué tan fuerte es el sprint).
- **2 salidas soportadas**: visual (animaciones del personaje y barra de estamina flotante) y auditiva (sonido al moverse y al chocar con los bordes de pantalla).
- Comparación de experiencia de usuario entre input binario (teclado) vs. input analógico (trackpad) para el mismo sistema de estamina — punto central de análisis de la materia.

## Estructura del proyecto
´´´
HCIProyect/
├── project.godot
├── scenes/
│ ├── main/ # main.tscn — escena principal
│ ├── player/ # Player.tscn
│ └── ui/ # botones UI, barra de estamina
├── scripts/
│ └── Player.gd # movimiento, estamina, ataque, animaciones, input trackpad
├── assets/
│ ├── sprites/
│ │ └── hero/
│ │ ├── idle/
│ │ ├── walk/
│ │ ├── jump/
│ │ ├── fall/
│ │ └── attack/
│ ├── audio/
│ │ ├── sfx/
│ │ └── music/
│ └── fonts/
└── docs/ # capturas, créditos, informe
´´´

## Cómo correr el proyecto

1. Abre Godot 4.x.
2. Importa la carpeta del proyecto (`project.godot`).
3. Ejecuta la escena `scenes/main/main.tscn`.

## Controles

**Teclado:**
- Flechas / `A` `D`: moverse izquierda/derecha.
- Flecha arriba: saltar.
- `Shift`: sprint (mantener presionado, consume estamina).
- Click izquierdo / tecla de ataque: atacar (consume estamina).

**Trackpad:**
- Swipe de 2 dedos izquierda/derecha: moverse (la velocidad del swipe controla la intensidad del sprint).
- Swipe de 2 dedos hacia arriba: saltar.

**Botones en pantalla:** disponibles como alternativa táctil a los controles de arriba (mover, saltar, sprint, atacar).

## Mecánica

- El personaje se mueve libremente dentro de los límites de la pantalla.
- La estamina se gasta al hacer sprint (más rápido si el swipe del trackpad es más intenso) y al atacar; se regenera automáticamente tras un breve tiempo sin usarse.
- Una barra de estamina flotante aparece sobre el personaje solo cuando no está al 100%, y desaparece al regenerarse por completo.
- El ataque tiene una animación de golpe seguida de una de recuperación antes de poder moverse con normalidad de nuevo.

## Créditos

- Animaciones del personaje: **Ozzbit Games** — [ozzbit-games.itch.io](https://ozzbit-games.itch.io) (versión gratuita, uso no comercial, créditos requeridos).

## Roadmap del semestre

- [x] Movimiento libre con teclado
- [x] Gravedad y salto
- [x] Sistema de estamina (sprint + ataque)
- [x] Animaciones del personaje (idle, walk, run, jump, fall, attack)
- [x] Input por trackpad (swipe analógico)
- [x] Barra de estamina flotante en UI
- [ ] Objetos recolectables en el nivel
- [ ] Escenario/nivel más allá de una sola pantalla
- [ ] Sonido adicional (ataque, recolección)
- [ ] Pruebas de usuario (HCI) comparando teclado vs. trackpad

## About

Sin descripción, sitio web, ni topics.