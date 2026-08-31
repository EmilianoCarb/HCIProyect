# 🦝 HCIProyect

Proyecto para la materia de **Interacción Humano-Computadora (HCI)**.
Desarrollado en **Godot 4.7** (GDScript).

---

## 🎮 Descripción

Juego de movimiento en cuadrícula donde un personaje (mapache) se desplaza por un tablero de 5×5 celdas. El proyecto explora dos modalidades de entrada y dos de salida, aplicando principios de usabilidad y diseño de interacción.

### Entradas (Inputs)

| # | Entrada | Detalle |
|---|---------|---------|
| 1 | **Teclado** | Flechas de dirección y teclas WASD |
| 2 | **Mouse / Pantalla táctil** | Botones direccionales en pantalla (D-Pad) |

### Salidas (Outputs)

| # | Salida | Detalle |
|---|--------|---------|
| 1 | **Visual** | Desplazamiento animado del sprite + efecto de sacudida al chocar con el borde |
| 2 | **Auditiva** | Sonido al moverse y al colisionar con el borde |

---

## 📁 Estructura del proyecto

```
HCIProyect/
├── project.godot            # Configuración del proyecto (ventana, input map, etc.)
├── icon.svg                 # Sprite del personaje (placeholder)
├── scenes/
│   └── main/
│       └── main.tscn        # Escena principal
├── scripts/
│   ├── Player.gd            # Lógica del personaje (movimiento, colisión, señales)
│   ├── Grid.gd              # Dibuja la cuadrícula visual con patrón de tablero
│   ├── DPad.gd              # Cruceta de botones direccionales (UI)
│   └── HUD.gd               # Muestra posición y contador de pasos
└── assets/
    ├── audio/                # Efectos de sonido (pendiente)
    └── sprites/              # Sprites del personaje (pendiente)
```

---

## 🚀 Cómo correr el proyecto

1. Abre **Godot 4.7**.
2. Importa la carpeta del proyecto (`project.godot`).
3. Ejecuta con **F5** (la escena principal ya está configurada).

---

## 🕹️ Controles

| Acción | Teclado | D-Pad (pantalla) |
|--------|---------|-------------------|
| Mover arriba | `↑` / `W` | Botón ▲ |
| Mover abajo | `↓` / `S` | Botón ▼ |
| Mover izquierda | `←` / `A` | Botón ◄ |
| Mover derecha | `→` / `D` | Botón ► |

---

## 🧠 Principios de HCI aplicados

- **Visibilidad del estado del sistema** — HUD con posición y pasos en tiempo real.
- **Retroalimentación multimodal** — Feedback visual (animación, shake) y auditivo (sonidos).
- **Ley de Fitts** — Botones del D-Pad con tamaño mínimo de 64×64px y disposición ergonómica.
- **Flexibilidad y eficiencia** — Dos métodos de entrada (teclado y mouse/touch).

---

## 👥 Equipo

Proyecto desarrollado para la Evaluación 1 de la materia de Interacción Humano-Computadora.
