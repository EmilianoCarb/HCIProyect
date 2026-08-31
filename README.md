# HCIProyect

Proyecto para la materia de Interacción Humano-Computadora (HCI).
Desarrollado en Godot 4 (GDScript).

## Evaluación 1 — Requisitos

- Movimiento de personaje (mapache) en 4 direcciones sobre una cuadrícula 5x5.
- 2 entradas soportadas: teclado y botones en pantalla (GUI/Mouse).
- 2 salidas soportadas: visual (desplazamiento del sprite) y auditiva (sonido al moverse y al chocar con el borde).

## Estructura del proyecto

```
HCIProyect/
├── project.godot
├── scenes/
│   └── main/          # main.tscn
├── scripts/            # Player.gd, UI.gd, etc.
└── assets/
    ├── audio/          # efectos de sonido
    └── sprites/        # sprite del mapache
```

## Cómo correr el proyecto

1. Abre Godot 4.x.
2. Importa la carpeta del proyecto (`project.godot`).
3. Ejecuta la escena `scenes/main/main.tscn`.

## Controles

- Flechas del teclado para mover al personaje.
- Botones en pantalla (Arriba/Abajo/Izquierda/Derecha) como entrada alternativa.
