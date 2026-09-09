# HCIProyect

Proyecto para la materia de Interacción Humano-Computadora (HCI).
Desarrollado en Godot 4 (GDScript).

## Descripción

Juego de tipo *endless runner*: un personaje (mapache) corre automáticamente por un escenario infinito, esquivando obstáculos y huyendo de un perseguidor que lo persigue y acelera con el tiempo. El objetivo es sobrevivir la mayor distancia/tiempo posible.

## Evaluación — Requisitos de HCI

- Movimiento del personaje (salto / deslizarse) en un escenario de scroll infinito.
- 2 entradas soportadas: teclado y gestos de trackpad (swipe de 2 dedos).
- 2 salidas soportadas: visual (animaciones del personaje y escenario) y auditiva (sonido al saltar, deslizar y al perder).

## Estructura del proyecto
```
HCIProyect/
├── project.godot
├── scenes/
│ ├── main/ # Main.tscn — orquesta la partida
│ ├── player/ # Player.tscn
│ ├── enemy/ # Perseguidor.tscn
│ ├── world/ # Segment.tscn, SegmentSpawner.tscn
│ └── ui/ # HUD, GameOver, MainMenu
├── scripts/
│ ├── player/
│ ├── enemy/
│ ├── world/
│ ├── managers/ # GameManager.gd, ScoreManager.gd
│ └── autoload/ # InputManager.gd (singleton)
├── assets/
│ ├── sprites/
│ │ ├── player/ # animaciones del personaje
│ │ └── enemy/
│ ├── audio/
│ │ ├── sfx/
│ │ └── music/
│ └── fonts/
└── docs/ # capturas, diagrama de nodos, créditos, informe

```
## Cómo correr el proyecto

1. Abre Godot 4.x.
2. Importa la carpeta del proyecto (`project.godot`).
3. Ejecuta la escena `scenes/main/main.tscn`.

## Controles

- **Teclado**: flecha arriba / `W` para saltar, flecha abajo / `S` para deslizarse.
- **Trackpad**: swipe de 2 dedos hacia arriba para saltar, hacia abajo para deslizarse.

## Mecánica

- El escenario se genera de forma infinita mediante segmentos que se instancian adelante y se eliminan atrás.
- El perseguidor avanza a velocidad constante que aumenta con el tiempo, incrementando la dificultad.
- El jugador pierde si el perseguidor lo alcanza o si choca contra un obstáculo.
- La distancia recorrida funciona como puntaje.

## Créditos

- Animaciones del personaje: _(agregar fuente y licencia aquí)_
- Sonidos: _(agregar fuente y licencia aquí)_

## Roadmap del semestre

- [x] Movimiento base con teclado
- [ ] Escenario infinito (spawner + pooling)
- [ ] Perseguidor con dificultad progresiva
- [ ] Input por trackpad
- [ ] Animaciones del personaje
- [ ] HUD y pantalla de Game Over
- [ ] Audio
- [ ] Pruebas de usuario (HCI)

## About

Sin descripción, sitio web, ni topics.
