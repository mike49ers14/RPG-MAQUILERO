# Maquila RPG — estilo Among Us (Godot 4)

Un solo jugador. Empiezas en tu casa, tomas el camión a la planta, haces
las 4 tareas en cualquier orden y regresas a dormir para el siguiente día.

---

## Cómo abrirlo

1. Descarga **Godot 4.4 o 4.5** (versión estándar, NO la .NET)
2. Abre Godot → **Import** → selecciona `project.godot`
3. **F5** para jugar (escena principal: `scenes/casa.tscn`)

## Controles

| Tecla | Acción |
|---|---|
| W A S D / flechas | Moverse |
| E | Interactuar con una estación / recoger o soltar la caja |
| Dentro de cada tarea: W A S D / Espacio | Responder al reto |

## Las 4 tareas

| Tarea | Estación | Mecánica |
|---|---|---|
| **Ensamble** | círculo azul | El minijuego de rate: piezas + tecla correcta a tiempo |
| **Calidad** | círculo rojo | Marca con ESPACIO solo las piezas defectuosas |
| **Checador** | círculo amarillo | QTE: presiona la tecla que se muestra antes de que se acabe el tiempo |
| **Almacén** | caja café → zona verde | Camina hacia la caja (E para cargarla), llévala a la zona verde (E para soltarla) |

El HUD (arriba a la derecha) muestra el checklist en vivo: `[x]` hecha, `[ ]` pendiente.

Cuando las 4 tienen `[x]`, ve al bloque morado ("Salida / fin de turno") y
presiona E: te regresa a casa. Ahí, habla con la **Cama** para dormir —
eso avanza el día, quita la fatiga y reinicia las 4 tareas para el
siguiente turno.

## El loop completo

```
casa.tscn  →  planta.tscn  →  casa.tscn  →  planta.tscn  → ...
 (mamá,        (4 tareas,       (dormir en
  camión)       salida)          la cama)
```

Al llegar a la planta la primera vez estás "Desempleado"; en cuanto
completas tu primera tarea de Ensamble, quedas contratado automáticamente
como Operador de línea.

## Estructura

```
project.godot          Escena principal: scenes/planta.tscn
scripts/
  game_state.gd         AUTOLOAD: dinero, fatiga, día, guardado
  quest_manager.gd       AUTOLOAD: lista plana de 4 tareas (sin orden)
  player.gd               Movimiento + interacción
  sala.gd                  Piso y muros por código
  estacion.gd              Estación genérica: abre el overlay de una tarea
  minijuego.gd             Tarea "Ensamble" (rate)
  tarea_calidad.gd          Tarea "Calidad"
  tarea_checador.gd         Tarea "Checador" (QTE)
  almacen_caja.gd / almacen_zona.gd   Tarea "Almacén" (cargar y entregar)
  salida_turno.gd            Punto de salida: exige las 4 tareas completas
  npc.gd / puerta.gd          Quedan del prototipo anterior, sin usar en planta.tscn
ui/
  ui_layer.gd/.tscn      AUTOLOAD: HUD con checklist + avisos + diálogo
scenes/
  planta.tscn             EL MAPA ÚNICO
  minijuego / tarea_calidad / tarea_checador .tscn   Overlays de cada tarea
  casa.tscn / rh.tscn       Prototipo anterior (RPG lineal), ya no se usan
```

## Cómo agregar una 5ta tarea

1. Registra el id en `scripts/quest_manager.gd` → diccionario `tareas`
2. Crea el script/escena de la tarea (Control de pantalla completa),
   con `signal tarea_terminada` y que llame `QuestManager.completar("tu_id")`
   antes de cerrarse
3. En `planta.tscn`, agrega un `Area2D` con `estacion.gd`, apuntando
   `escena_tarea` a tu nueva escena

## Pendientes (ruta de las 3 semanas)

- [ ] Reemplazar ColorRect por sprites (Kenney / LimeZu) — ya en progreso
- [ ] TileMapLayer para el piso de `planta.tscn`
- [ ] Animaciones de caminado
- [ ] Audio: ambiente de planta + SFX por tarea
- [ ] Menú principal y pantalla de créditos
- [ ] Balancear dificultad de cada tarea
- [ ] Export a .exe y a Web (HTML5)
