# RaidMark — Mesa de Tácticas para Raids

> Addon de World of Warcraft **1.12 / Vanilla** para servidores privados (Turtle WoW).  
> Diseñado para Raid Leaders que necesitan comunicar estrategias visualmente en tiempo real.

---

## ✨ Características principales

- 🗺️ **Mapa táctico interactivo** con 30+ encuentros de AQ40 y Naxxramas
- 🔴 **Iconos de rol** arrastrables: Tank, Healer, DPS, Círculos, Marcas de raid, Calaveras
- 🏹 **Flechas direccionales** (N/S/E/O/NE/NO/SE/SO) con stretch ajustable
- 👥 **Panel de raiders** con asignación de roles, filtros y herramientas de posicionamiento
- 💾 **Sistema de escenas** — 40 slots locales (10 GrandSlots × 4)
- 🎯 **Modo de posicionamiento** — diseña en offline, sincroniza raiders reales con un click
- 📡 **Sincronización en red** — todo el raid ve los cambios en tiempo real
- 🔇 **Modo Offline** — diseña estrategias sin conexión al raid

---

## 📦 Instalación

1. Descarga el `.zip` desde el Github
2. Extrae la carpeta `RaidMark` en:
   `World of Warcraft\Interface\AddOns\`
3. Reinicia el juego o escribe `/reload`
4. Abre con `/rm` o `/raidmark`
*. Opcionalmente puedes usar el link de Github para instalar el addon desde el launcher de turtle wow.

---

## 🎮 Uso básico

### Abrir el mapa
```
/rm
```

### Seleccionar un encuentro
Haz click en el botón **▼ Encounter** (esquina superior izquierda del mapa).

### Colocar iconos
1. Selecciona un ícono del panel derecho
2. Haz click izquierdo en el mapa para colocarlo
3. **Arrastra** para moverlo · **Click derecho** para eliminar

### Flechas direccionales
- Click en el botón de flecha → se abre un **dropdown** con 8 direcciones (N/S/E/O/NE/NO/SE/SO)
- Cada flecha tiene 3 variantes de color: **Rojo**, **Blanco**, **Amarillo**
- En el lienzo, la flecha tiene un **cuadrado verde central (hitbox)**:
  - **Drag** sobre el hitbox = mover la flecha
  - **Rueda del mouse** sobre el hitbox = estirar/encoger *(solo RL y Assists)*
  - Flechas N/S estiran verticalmente · E/O estiran horizontalmente
  - Flechas diagonales escalan de forma uniforme
- **Click derecho** sobre el hitbox = eliminar

---

## 👥 Roles y permisos

| Rol | Permisos |
|-----|----------|
| **Raid Leader (RL)** | Todo: colocar, mover, borrar, sync, offline, escenas, auto-asignar |
| **Assist** | Colocar y mover iconos |
| **Raider** | Solo ver |

- Activa permisos de Assist con el botón **Assist: ON/OFF**
- Al entrar en **Modo Offline**, el Assist se desactiva automáticamente y se restaura al salir

---

## 💾 Sistema de Escenas

Guarda hasta **40 disposiciones** del lienzo:
- **4 slots rápidos** (`1 2 3 4`) · **10 GrandSlots** (dropdown `GS1 ▼`)
- Las escenas se guardan localmente y **persisten entre sesiones**

### Colores de los slots

| Color | Significado |
|-------|-------------|
| ⬜ Gris | Vacío |
| 🔴 Rojo | Seleccionado (listo para guardar o usar con Sync P) |
| 🟠 Naranja | Seleccionado con contenido (segundo click = cargar) |
| 🟡 Amarillo | Tiene contenido guardado |
| 🟢 Verde | **Mapa de posicionamiento** (contiene posiciones de raid) |

### Guardar una escena
1. Selecciona un slot → se pone **rojo**
2. Presiona **[S]** (disquete)
3. Si el lienzo está vacío, el slot se **limpia** (equivale a borrar el slot)

### Cargar una escena
- Click en slot → primer click = seleccionar (rojo/naranja)
- Segundo click = **cargar** al lienzo y broadcastear al raid

> Los slots verdes (posicionamiento) cargan los cuadritos de posición **solo localmente** — el raid no los ve hasta que el RL usa **Sync P**

---

## 🎯 Modo de Posicionamiento

Diseña dónde va cada rol antes del pull, sin necesidad de estar en raid.

### Crear un mapa de posicionamiento

1. Presiona **M Offline** → aparece advertencia → presiona de nuevo para confirmar
2. El panel de raiders muestra iconos de rol con sus colores:

| Ícono | Color | Rol |
|-------|-------|-----|
| Tank | 🔵 Azul | Tank |
| Healer | 🟢 Verde | Healer |
| DPS Melee | 🔴 Rojo | DPS Melee |
| DPS Rang | 🟠 Naranja | DPS a Rango |
| Edit | ⬜ Gris | Uso futuro |

3. Coloca hasta **40 posiciones** en el mapa *(solo en Modo Offline)*
4. Guarda en un slot → el slot se pinta **verde**
5. Presiona **M Offline** para salir

> Para ajustar posiciones: entra al Modo Offline, edita, guarda, sal.

### Usar el mapa en raid (Sync P)

1. **Selecciona el slot verde** con un click → se pone rojo
2. Presiona **Sync P** → el addon coloca automáticamente cada raider en su posición

**Reglas del Sync P:**
- Cada cuadrito = exactamente un raider
- Los raiders ya colocados manualmente tienen **prioridad** — Sync P no los mueve
- Sync P busca el primer slot libre de su rol para cada raider que falta
- Si hay más raiders del mismo rol que cuadritos, los sobrantes no se colocan
- **Se puede presionar Sync P múltiples veces** sin riesgo de duplicados
- Los cuadritos de posición son **solo visibles para el RL** — los raiders nunca los ven
- Los cuadritos solo desaparecen al presionar **Limpiar**

> **Reset P** — devuelve todos los raiders del lienzo al panel en un click

---

## 🤖 Auto-asignación de roles

El RL puede asignar roles automáticamente via chat de `/raid`.

> **Solo puede correr un auto-asignador a la vez.** Si hay uno activo, los demás están bloqueados hasta que termine.

> **Los roles asignados se guardan entre sesiones.** Sobreviven a `/reload` y reinicios. Las respuestas nuevas *sobreescriben* el rol anterior raider por raider, sin afectar a los demás.

### Botones individuales *(10 segundos)*

Presiona **Healer**, **DD M**, **DD R** o **Tank**.
Sale en `/rw`: *"Todos los Healers escriban [1] en /raid"*
Los últimos **3 segundos** se spamea la cuenta regresiva.

### Auto-Total *(20 segundos)*

Pide todos los roles a la vez:
*"Escribe tu número: 1=Healer // 2=DPS Melee // 3=DPS Rango // 4=Tank"*
Al terminar reporta cuántos del total respondieron.

| Número | Rol |
|--------|-----|
| `1` | Healer |
| `2` | DPS Melee |
| `3` | DPS a Rango |
| `4` | Tank |

> Solo escucha el canal `/raid`. Requiere estar en un raid activo.

### Dots de rol (panel de raiders)

Cada raider en el panel tiene **4 puntitos** a su derecha (H · D · D · T).
- Click en un puntito = asignar ese rol manualmente
- Click de nuevo en el mismo = quitar el rol
- Solo un rol por raider
- Los puntitos se actualizan en tiempo real

### Filtrar raiders

Encima del panel de raiders hay tres botones compactos:
- **[v]** — abre dropdown para seleccionar rol (Healer / DPS Melee / DPS Rang / Tank)
- **[Filtrar]** — los raiders del rol seleccionado aparecen primero en la lista
- **[Reset P]** — devuelve todos los raiders del lienzo al panel

---

## 🔇 Modo Offline

Permite diseñar estrategias sin afectar al raid ni requerir estar en grupo.

**Al entrar:**
- Advertencia en el box → segundo click confirma
- Se limpia el lienzo
- Si hay Assist activo, se desactiva automáticamente
- Toda red queda bloqueada
- El box muestra `[ MODO OFFLINE ]` en rojo periódicamente

**Al salir:**
- Se limpia el lienzo
- El Assist se restaura si estaba activo antes

**Bloqueado en Modo Offline:** Sync · Auto-assign · Auto-Total · Sync P

**Disponible en Modo Offline:** Sistema de escenas · Grid · Iconos · Flechas · Panel de posicionamiento

---

## 🗺️ Encuentros incluidos

**AQ40:** Twin Emperors · C'Thun Exterior · C'Thun Estómago · Skeram · Ouro · Huhuran · Viscidus · Fankriss · Sartura · Bug Trio

**Naxxramas:** Anub'Rekhan · Faerlina · Maexxna · Noth · Heigan · Loatheb · Razuvious · Gothik · 4 Horsemen · Patchwerk · Grobbulus · Gluth · Thaddius · Sapphiron · Kel'Thuzad

---

## ⚙️ Comandos slash

| Comando | Función |
|---------|---------|
| `/rm` | Abrir / cerrar el mapa |
| `/rm clear` | Limpiar todos los iconos |
| `/rm map <key>` | Cambiar mapa (ej: `twin_emperors`) |
| `/rm assist on/off` | Habilitar/deshabilitar permisos de Assist |

---

## 📝 Notas técnicas

- Protocolo de red propio via `SendAddonMessage` con separador `;`
- `SavedVariables`: `RaidMarkDB` (configuración + roles) · `RaidMarkSceneDB` (escenas)
- Los roles de raid persisten en disco — sobreviven a `/reload` y reinicios
- Los cuadritos de posicionamiento **nunca se broadcastean** — son exclusivamente locales para el RL
- Compatible con grupos de party (no solo raids)
- Las flechas usan TGAs personalizados de 256×256
- Límite de **40 posiciones** de rol en Modo Offline por sesión

---

## 👤 Autor

**Holle** — Turtle WoW
*"By Holle - South Seas Server"*
