# RaidMark — Mesa de Tácticas para Raids

> Addon de World of Warcraft **1.12 / Vanilla** para servidores privados (Turtle WoW).  
> Diseñado para Raid Leaders y Asistentes que necesitan comunicar estrategias visualmente en tiempo real.

---

## ✨ Características principales

- 🗺️ **Mapa táctico interactivo** con 30+ encuentros de AQ40 y Naxxramas
- 🔴 **Iconos de rol** arrastrables: Tank, Healer, DPS, Círculos, Marcas de raid, Calaveras
- 🏹 **Flechas direccionales** (N/S/E/O/NE/NO/SE/SO) con stretch ajustable por rueda del mouse
- 👥 **Panel de raiders** con asignación de roles, filtros y herramientas de posicionamiento
- 💾 **Sistema de escenas** — 40 slots locales (10 GrandSlots × 4) para todos los jugadores
- 🎯 **Modo de posicionamiento** — diseña en offline, sincroniza raiders reales con un click
- 📡 **Sincronización en red inteligente** — throttle automático según cantidad de íconos
- 🔇 **Modo Offline** — diseña estrategias sin afectar al raid
- 📊 **Monitor de memoria** — alerta progresiva con opción de deshabilitar

---

## 📦 Instalación

1. Descarga el `.zip` desde [Releases](../../releases)
2. Extrae la carpeta `RaidMark` en:
   `World of Warcraft\Interface\AddOns\`
3. Reinicia el juego o escribe `/reload`
4. Abre con `/rm` o `/raidmark`

---

## 🎮 Uso básico

### Abrir el mapa
```
/rm
```

### Seleccionar un encuentro
Haz click en el botón **▼ Encounter** (esquina superior izquierda del mapa).

### Colocar íconos
1. Selecciona un ícono del panel derecho
2. Haz click izquierdo en el mapa para colocarlo
3. **Arrastra** para moverlo · **Click derecho** para eliminar

### Escala y posición
- Botón **Scale** (esquina superior derecha) — cicla entre 100% / 90% / 80%
- Arrastra la barra de título para mover el addon
- **La posición y escala se guardan entre sesiones** — no hace falta reconfigurar al entrar

### Flechas direccionales
- Click en el botón de flecha → dropdown con 8 direcciones × 3 colores (Rojo / Blanco / Amarillo)
- El **cuadrado verde (hitbox)** en el centro de cada flecha:
  - **Drag** = mover · **Click derecho** = eliminar
  - **Rueda del mouse** = estirar/encoger *(solo RL y Assists)*
  - Flechas N/S → estiran verticalmente · E/O → horizontalmente · Diagonales → escala uniforme

---

## 👥 Roles y permisos

| Rol | Íconos | Escenas | Auto-assign | Modo Offline |
|-----|--------|---------|-------------|--------------|
| **Raid Leader** | ✅ Total | ✅ Guardar + Cargar | ✅ Total | ✅ Total |
| **Assist** | ✅ Colocar/Mover | ✅ Guardar + Cargar en Offline | ✅ Puede lanzar | ✅ Total |
| **Raider** | ❌ Solo ver | ✅ Solo guardar local | ❌ | ✅ Total |

- Activa permisos de Assist con el botón **Assist: ON/OFF** en la toolbar
- Al entrar en Modo Offline el Assist se desactiva automáticamente y se restaura al salir

---

## 💾 Sistema de Escenas

Guarda hasta **40 disposiciones** del lienzo organizadas en:
- **4 slots rápidos** (`1 2 3 4`) — **10 GrandSlots** (dropdown `GS▼`)
- Las escenas se guardan **localmente por jugador** y persisten entre sesiones

### Colores de slots

| Color | Significado |
|-------|-------------|
| ⬜ Gris | Vacío |
| 🔴 Rojo + **v** | Seleccionado (listo para guardar, cargar o borrar) |
| 🟠 Naranja + **v** | Seleccionado con contenido (segundo click = cargar) |
| 🟡 Amarillo | Tiene contenido guardado |
| 🟢 Verde | **Mapa de posicionamiento** |

> La **v** aparece flotando encima del slot activo — el color del slot nunca cambia por la selección, siempre refleja el contenido real.

### Botones de la toolbar de escenas

| Botón | Función |
|-------|---------|
| **[S]** | Guardar lienzo en slot seleccionado. Si el lienzo está vacío, **borra el slot** |
| **[B]** | Borrar slot seleccionado — primer click pide confirmación en el box, segundo click borra |
| **1 2 3 4** | Seleccionar slot rápido del GrandSlot activo |
| **GS▼** | Dropdown de 10 GrandSlots con contador de slots ocupados |

### Cargar una escena
- Primer click → seleccionar (v roja/naranja)
- Segundo click → cargar al lienzo y broadcastear al raid *(solo RL, o cualquiera en Modo Offline)*

---

## 🎯 Modo de Posicionamiento

Diseña dónde va cada rol antes del pull. Disponible para **todos** en Modo Offline.

### Crear un mapa de posicionamiento

1. Presiona **M Offline** → confirma en el segundo click
2. Coloca hasta **40 cuadritos de posición** (solo en Modo Offline):

| Cuadrito | Color | Rol |
|----------|-------|-----|
| Tank | 🔵 Azul | Tank |
| Healer | 🟢 Verde | Healer |
| DPS Melee | 🔴 Rojo | DPS Melee |
| DPS Rang | 🟠 Naranja | DPS a Rango |

3. Guarda en un slot → se pinta **verde**
4. Sal del Modo Offline

> Los cuadritos de posición **solo se pueden colocar y mover en Modo Offline** — en modo normal son visibles como referencia pero no editables.

### Usar el mapa en raid

1. **Selecciona el slot verde** (un click → se pone rojo)
2. Presiona **Sync P** → cada raider con rol asignado se coloca en su posición

**Reglas de Sync P:**
- Raiders ya colocados manualmente tienen **prioridad** — Sync P no los mueve
- Busca el **primer slot libre** de su rol — nunca duplica raiders
- Se puede presionar **múltiples veces** sin riesgo (conectados tarde, rotación de posiciones)
- Los cuadritos son **solo visibles para el RL** — el raid nunca los ve
- Los cuadritos desaparecen solo al presionar **Limpiar**

### Botones del panel de raiders

| Botón | Disponible para | Función |
|-------|----------------|---------|
| **[v]** | Todos | Dropdown para elegir rol de filtro |
| **[Filtrar]** | Todos | Ordena raiders por rol seleccionado primero |
| **[Reset P]** | RL | Devuelve todos los raiders del lienzo al panel |
| **[Env.Rol]** | Assists activos | Envía propuesta de roles al RL (rellena huecos sin sobreescribir) |
| **[Sync Rol]** | RL | Sincroniza todos los roles asignados al raid |

---

## 📡 Sincronización en red

### Sync inteligente con throttle automático

Al presionar **Sync**, el addon detecta cuántos íconos hay y elige el delay apropiado:

| Íconos | Delay | Tiempo total |
|--------|-------|-------------|
| 1–10 | Sin delay | Instantáneo |
| 11–25 | 0.05s entre msgs | ~1–2 seg |
| 26–50 | 0.15s entre msgs | ~5–7 seg |
| 50+ | 0.2s entre msgs | ~10 seg |

- El botón **Sync** se pone gris e inactivo durante el envío
- Los movimientos se pausan y se reanudan al terminar
- El box muestra `Sync [====    ] 45%` con porcentaje en tiempo real
- Los **moves individuales** en tiempo real son siempre instantáneos — el throttle solo aplica al Sync masivo

### Sync Rol
- **[Sync Rol]** (solo RL) envía todos los roles asignados al raid con micro-delay de 0.1s entre mensajes
- Los receptores actualizan su panel de raiders automáticamente

---

## 🤖 Auto-asignación de roles

> **Solo puede correr un auto-asignador a la vez.** Al iniciar uno, todos los clientes del raid bloquean sus botones durante la duración del proceso más 10 segundos de cooldown post-assign.

> **Los roles asignados se guardan entre sesiones.** Sobreviven a `/reload` y reinicios. Cada respuesta sobreescribe el rol anterior raider por raider.

### Botones individuales *(10 segundos)*

Presiona **Healer**, **DD M**, **DD R** o **Tank**.
- Sale en `/rw`: *"Todos los Healers escriban [1] en /raid"*
- Los últimos **3 segundos** se spamea la cuenta regresiva
- Solo escucha el canal `/raid`
- Disponible para **RL y Assists activos**

### Auto-Total *(20 segundos)*

*"Escribe tu número: 1=Healer // 2=DPS Melee // 3=DPS Rango // 4=Tank"*

Al terminar reporta cuántos del total respondieron.

| Número | Rol |
|--------|-----|
| `1` | Healer |
| `2` | DPS Melee |
| `3` | DPS a Rango |
| `4` | Tank |

### Dots de rol (panel de raiders)

Cada raider tiene **4 puntitos** (H · D · D · T) — click activa/desactiva el rol. Disponible para **RL y Assists activos**.

### Envío de roles entre Assist y RL

- El Assist asigna roles localmente via dots o auto-assign
- Presiona **[Env.Rol]** para proponer sus roles al RL
- El RL recibe y aplica **solo los raiders sin rol asignado** — nunca sobreescribe los suyos
- Throttle de 15 segundos entre envíos para no saturar el canal

### Filtrar raiders por rol

1. Click en **[v]** → selecciona rol
2. Click en **[Filtrar]** → los raiders del rol aparecen primero en la lista

---

## 🔇 Modo Offline

Disponible para **todos** (RL, Assist, Raiders).

**Al entrar:**
- Advertencia en el box → segundo click confirma
- Se limpia el lienzo local
- Si hay Assist activo, se desactiva automáticamente
- Toda red queda bloqueada — ningún mensaje entra ni sale
- El box muestra `[ MODO OFFLINE ]` en rojo periódicamente

**Al salir:**
- Se limpia el lienzo local
- El Assist se restaura si estaba activo antes

**Bloqueado en Modo Offline:** Sync · Sync P · Auto-assign · Auto-Total

**Disponible en Modo Offline:** Sistema de escenas (guardar + cargar) · Grid · Íconos · Flechas · Panel de posicionamiento

---

## 🗺️ Encuentros incluidos

**AQ40:** Twin Emperors · C'Thun Exterior · C'Thun Estómago · Skeram · Ouro · Huhuran · Viscidus · Fankriss · Sartura · Bug Trio

**Naxxramas:** Anub'Rekhan · Faerlina · Maexxna · Noth · Heigan · Loatheb · Razuvious · Gothik · 4 Horsemen · Patchwerk · Grobbulus · Gluth · Thaddius · Sapphiron · Kel'Thuzad

---

## 🖥️ Monitor de memoria

WoW vanilla asigna un pool de memoria fijo para addons — independiente de la RAM del jugador. RaidMark monitorea los frames creados en la sesión y avisa cuando se acerca al límite.

| Umbral | Tipo | Comportamiento |
|--------|------|----------------|
| **700 frames** | ⚠️ Amigable | Mensaje en box cada 20 seg + cuadrado **azul** encima del box |
| **1100 frames** | 🔴 Crítico | Parpadeo rojo/amarillo en el box + cuadrado **rojo** encima del box |

- Al aparecer la alarma, un cuadrado aparece **encima del box informativo** con el texto *"deshabilitar alarma"* a su izquierda
- Click en el cuadrado → la alarma se deshabilita y el cuadrado desaparece
- La alarma crítica usa texto en **MAYÚSCULAS** y parpadeo — una vez deshabilitada es responsabilidad del usuario
- La solución definitiva es siempre `/reload`

---

## ⚙️ Comandos slash

| Comando | Función |
|---------|---------|
| `/rm` | Abrir / cerrar el mapa |
| `/rm clear` | Limpiar todos los íconos |
| `/rm map <key>` | Cambiar mapa (ej: `twin_emperors`) |
| `/rm assist on/off` | Habilitar/deshabilitar permisos de Assist |

---

## 🔧 Requisitos

- World of Warcraft **1.12.1** (Vanilla)
- Servidor: **Turtle WoW** u otro servidor 1.12 compatible
- Se requiere ser **Raid Leader** para las funciones tácticas principales

---

## 📝 Notas técnicas

- Protocolo de red propio via `SendAddonMessage` con separador `;` — nunca usa `|` (reservado por WoW para color codes)
- `SavedVariables`: `RaidMarkDB` (config + roles + posición + escala) · `RaidMarkSceneDB` (escenas por jugador)
- Los roles persisten en disco — sobreviven a `/reload` y reinicios
- Los cuadritos de posicionamiento **nunca se broadcastean** — exclusivamente locales para el RL
- El throttle de Sync es automático y transparente para el usuario
- Escala (80%/90%/100%) y posición del addon se guardan y restauran entre sesiones
- Límite de **40 posiciones** de rol por mapa de posicionamiento
- Compatible con grupos de party (no solo raids)

---

## 👤 Autor

**Holle** — Turtle WoW  
*"By Holle - South Seas Server"*
