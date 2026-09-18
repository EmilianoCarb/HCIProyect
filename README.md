# Plataformas & Interacción: Evaluación de Modalidades de Entrada

> **Proyecto Académico — Interacción Humano-Computadora (IHC / HCI)**  
> Desarrollado con **Godot Engine 4 (GDScript)**.

---

## 1. Resumen Ejecutivo

Este proyecto investiga cómo diferentes modalidades de interacción física afectan la experiencia de usuario, la carga motriz y la eficiencia en el control de un avatar dentro de un entorno 2D interactivo.

En los videojuegos y aplicaciones interactivas contemporáneas, la mayoría de los esquemas de control asumen una entrada **discreta (binaria)** a través de teclas (`0` o `1`). Este proyecto introduce y compara formalmente una entrada **continua (analógica)** basada en gestos sobre panel táctil (*trackpad swipe* sin clic forzado) y una entrada **asistida mediante interfaz táctil/puntero único (botones UI)** orientada a la accesibilidad.

El sistema se articula alrededor de un recurso limitante común: **la estamina**, permitiendo observar de forma cuantificable cómo cada tipo de entrada influye en la precisión y dosificación del esfuerzo del usuario.

---

## 2. Marco Teórico de Interacción Humano-Computadora (IHC)

### 2.1. Dimensionalidad y Dinámica del Input
* **Entrada Discreta (Teclado / Botones):** Transición instantánea entre dos estados de velocidad: *caminar* ($v = 250\text{ px/s}$) y *sprint* ($v = 450\text{ px/s}$). Demanda una carga cognitiva baja en la activación, pero carece de granularidad intermedia.
* **Entrada Continua (Trackpad Gestual):** Basada en la velocidad temporal del gesto de dos dedos. El juego mide el intervalo $\Delta t$ entre eventos consecutivos generados por el compositor:
  $$\text{Intensidad} = \text{lerp}\left(1.0, \text{Intensidad}_{\min}, \text{clamp}\left(\frac{\Delta t}{\text{Ventana}_{\text{rápida}}}, 0, 1\right)\right)$$
  La velocidad resultante es continua:
  $$v = \text{lerp}(v_{\text{walk}}, v_{\text{sprint}}, |\text{Intensidad}|)$$
  Esto permite al usuario modular su velocidad y dosificar el consumo de estamina en una escala analógica sin saltos bruscos.

### 2.2. Ley de Fitts y Affordance en Pantalla
Para la modalidad asistida en pantalla, los botones virtuales están ubicados en las esquinas inferiores (zonas de fácil alcance motor para pulgares en pantallas táctiles o baja distancia de desplazamiento de cursor con puntero único), maximizando el índice de rendimiento motriz y minimizando el tiempo de adquisición del objetivo según la formulación de Fitts:
$$MT = a + b \cdot \log_2\left(\frac{2D}{W}\right)$$

---

## 3. Mapeo de Entradas por Perfiles de Usuario (Personas)

El sistema fue diseñado considerando tres perfiles con capacidades y preferencias físicas distintas:

| Perfil de Usuario | Canal de Entrada Preferido | Justificación de IHC / Accesibilidad |
|---|---|---|
| **Persona A: Usuario de Escritorio Estándar** | **Teclado Físico** (`WASD` / Flechas + `Shift` + Espacio) | Respuesta táctil mecánica inmediata, bajo índice de error por rebote, ideal para usuarios acostumbrados a controles tradicionales de videojuegos. |
| **Persona B: Usuario de Portátil (Laptop)** | **Trackpad Multitáctil** (Swipe de 2 dedos sin clic) | Reduce el estrés en tendones y articulaciones al eliminar la necesidad de clics mecánicos sostenidos. Permite control de velocidad gradual con gestos naturales de deslizamiento. |
| **Persona C: Accesibilidad / Puntero Único / Táctil** | **Botones Virtuales en Pantalla** + **Toggle de Trackpad** | Pensado para personas con movilidad reducida en dedos que emplean emuladores de ratón, dispositivos *head-tracking* de un solo botón o pantallas táctiles. |

---

## 4. Esquema de Controles

### Resumen Comparativo de Acciones

| Acción | Modalidad 1: Solo Teclado | Modalidad 2: Solo Gestos Trackpad (2 Dedos) | Modalidad 3: Solo Botones UI (Táctil / Cursor) |
|---|---|---|---|
| **Moverse (Caminar)** | Flechas `◀` `▶` o `A` / `D` | Deslizamiento suave horizontal | Clic / Toque sostenido en `◀` o `▶` |
| **Correr (Sprint)** | Mantener tecla `Shift` | Deslizamiento rápido horizontal | Clic / Toque sostenido en `⚡ Sprint` |
| **Saltar** | Flecha `▲`, `W` o barra `Espacio` | Deslizamiento rápido hacia **arriba** | Clic / Toque en `▲ Saltar` |
| **Golpe / Ataque** | Tecla `J` o `Z` (o Clic izq) | Deslizamiento rápido hacia **abajo** | Clic / Toque en `⚔ Golpe` |
| **Invertir Sentido Trackpad** | N/A | Ajustable en vivo con botón superior | Botón `Trackpad: Natural / Invertido` |

> [!IMPORTANT]
> **Paridad Completa de Control:** Las tres modalidades son **100% autosuficientes**. Un usuario puede jugar de principio a fin utilizando **únicamente el teclado** (sin tocar el ratón ni la pantalla), **únicamente gestos sobre el trackpad** (sin pulsar teclas ni clics físicos) o **únicamente la interfaz táctil en pantalla**.

> [!NOTE]
> **Adaptabilidad de Sistema:** Los sistemas operativos manejan la dirección del scroll ("desplazamiento natural" invertido) de manera dispar según las preferencias del usuario. La interfaz incluye un botón en tiempo de ejecución (`Trackpad: Natural (ON/OFF)`) para que cualquier participante de prueba calibre el sentido del movimiento al instante sin requerir modificar ajustes del sistema ni reconfigurar el código.

---

## 5. Mecánicas de Juego y Ciclo de Feedback

1. **Gestión de Estamina:**
   - La estamina máxima es $100$.
   - **Sprint:** Consume $30\text{ unidades/segundo} \times \text{Intensidad}$ (en trackpad, la tasa de gasto es proporcional a la velocidad real).
   - **Ataque:** Costo fijo discreto de $25\text{ unidades}$.
   - **Regeneración:** Tras un retraso de inactividad de $0.2\text{ s}$, se recupera a razón de $25\text{ unidades/segundo}$.
2. **Feedback Visual Adaptativo:**
   - Una barra de progreso (`ProgressBar`) permanece invisible cuando el recurso está al $100\%$, reduciendo el ruido visual (*clutter* cognitivo).
   - Aparece sobre el personaje automáticamente al consumir energía y refleja el valor exacto en tiempo real.
3. **Profundidad y Cámara:**
   - Fondo con capas `Parallax2D` diferenciadas (cielo planetario a escala $0.2$ y ruinas de primer plano a escala $0.7$) para proveer retroalimentación visual de velocidad y desplazamiento relativo.
   - `Camera2D` con límites automáticos de nivel ($0$ a $3000\text{ px}$ en horizontal).

---

## 6. Arquitectura del Proyecto (Godot 4)

El proyecto sigue una arquitectura **limpia y desacoplada**, guiada por la eliminación sistemática de sobreingeniería:

```
HCIProyect/
├── project.godot           # Configuración del motor, mapeo de acciones de entrada
├── scenes/
│   └── main/
│       ├── main.tscn       # Escena principal (Fondo, Parallax, Player, Cámara, UI)
│       └── ui.gd           # Capa UI: conexión unificada a Input actions y toggle de trackpad
├── scripts/
│   └── Player.gd           # Físicas, estamina, animaciones y decodificación de gestos de trackpad
└── assets/
    ├── sprites/            # Spritesheets de personaje y escenarios
    └── audio/              # Efectos auditivos
```

### Principios de Implementación
* **Pipeline Unificado de Entrada:** La interfaz de usuario no manipula variables internas del jugador; inyecta eventos nativos a través de `Input.action_press()` y `Input.action_release()`. Esto desacopla totalmente la lógica de presentación de la lógica de juego.
* **Aprovechamiento Nativo del Motor:** Los límites de cámara y la reproducción automática de animaciones de fondo se gestionan mediante propiedades nativas de los nodos (`Camera2D.limit_*`, `AnimatedSprite2D.autoplay`), evitando scripts delegadores innecesarios.

---

## 7. Metodología de Evaluación con Usuarios

Para el informe final de la materia de IHC, se recomienda el siguiente protocolo de prueba:

### 7.1. Diseño Experimental (Within-Subjects A/B)
Cada participante realiza un recorrido idéntico con ambas modalidades principales en orden contrabalanceado para mitigar el sesgo de aprendizaje:
* **Condición A:** Teclado físico convencional.
* **Condición B:** Trackpad analógico con swipe de dos dedos.

### 7.2. Métricas de Recolección

| Tipo de Métrica | Variable Medida | Instrumento / Método |
|---|---|---|
| **Cuantitativa (Eficiencia)** | Tiempo total de completación de recorrido | Cronometraje automático |
| **Cuantitativa (Precisión)** | Número de veces que la estamina se agotó involuntariamente ($= 0$) | Registro por software |
| **Cuantitativa (Adquisición)** | Tasa de acierto al saltar obstáculos en el primer intento | Conteo de reintentos |
| **Cualitativa (Carga de Trabajo)** | Esfuerzo físico, mental y frustración percibida | Escala NASA-TLX |
| **Cualitativa (Usabilidad)** | Nivel general de satisfacción del sistema | Cuestionario SUS (*System Usability Scale*) |

---

## 8. Cómo Ejecutar el Proyecto

1. Descargar e instalar **Godot Engine 4.x** (Standard o .NET, Forward+ / Mobile compatible).
2. Clonar este repositorio:
   ```bash
   git clone https://github.com/EmilianoCarb/HCIProyect.git
   ```
3. En el Administrador de Proyectos de Godot, pulsar **Importar** y seleccionar el archivo `project.godot`.
4. Presionar `F5` o pulsar el botón **Reproducir** para ejecutar la escena `scenes/main/main.tscn`.

---

## 9. Créditos y Licencias

* **Animaciones de Personaje:** Ozzbit Games ([ozzbit-games.itch.io](https://ozzbit-games.itch.io)) — Licencia de uso no comercial con atribución.
* **Fondo (Cielo y Planeta):** Arte procedural pixel art para ambientación de ciencia ficción.
* **Tileset de Entorno:** Maaot (*Mossy Cavern Tileset*, [maaot.itch.io/mossy-cavern](https://maaot.itch.io/mossy-cavern)).
* **Investigación y Desarrollo:** Proyecto desarrollado para la materia de Interacción Humano-Computadora.
