# RaidMark - Turtle WoW 1.12

[cite_start]**Autor:** Holle [cite: 11]  
[cite_start]**Versión:** 0.81 [cite: 6]  
[cite_start]**Servidor:** Turtle WoW (WoW vanilla 1.12 - South Seas server) [cite: 2, 8]

---

## 📝 Descripción
[cite_start]**RaidMark** es una mesa de tácticas para raids que permite al **Raid Leader** colocar íconos sobre un mapa 2D táctico del encuentro[cite: 1, 4, 13]. [cite_start]Estos se sincronizan en tiempo real con todos los miembros de la raid para coordinar movimientos y estrategias[cite: 13].

## 🛠 Instalación
1. [cite_start]**Cierra el juego** completamente[cite: 16].
2. Copia la carpeta `RaidMark` dentro de:  
   [cite_start]`World of Warcraft\Interface\AddOns\RaidMark\`[cite: 17, 18].
3. [cite_start]**(Opcional):** Puedes usar el link de GitHub e instalarlo desde el launcher de Turtle WoW en la carpeta `Cache`[cite: 19, 20].

## 🚀 Primeros Pasos

### Abrir el Addon
Escribe en el chat el comando:  
[cite_start]`/rm` [cite: 24]  
[cite_start]Esto abre o cierra la ventana de RaidMark, la cual es arrastrable[cite: 25, 26].

### Seleccionar el Encuentro
[cite_start]Usa el menú desplegable en la esquina superior izquierda de la toolbar para elegir el mapa[cite: 28].  
[cite_start]**Mapas disponibles:** 
* [cite_start]Profeta Skeram [cite: 30]
* [cite_start]Bug Trio (Yauj, Vem, Kri) [cite: 31]
* [cite_start]Sartura [cite: 31]
* [cite_start]Fankriss el Incansable [cite: 32]
* [cite_start]Viscidus [cite: 33]
* [cite_start]Princesa Huhuran [cite: 34]
* [cite_start]Señor Ouro [cite: 35]
* [cite_start]Twin Emperors [cite: 36]
* [cite_start]C'Thun (Sala Exterior y Estómago) [cite: 37, 39, 40]

## 📍 Gestión de Íconos
[cite_start]El panel derecho organiza los íconos en tres categorías principales: 

| Categoría | Íconos Incluidos |
| :--- | :--- |
| **Roles** | [cite_start]Tank, Healer, DPS ranged, DPS melee, Caster y Flecha[cite: 43, 44, 45, 46, 47, 48, 49]. |
| **Áreas** | [cite_start]Círculos de tamaños S, M, L y XL[cite: 50, 51, 52, 53, 54]. |
| **Miembros** | [cite_start]Listado de miembros del raid con nombre y color de clase[cite: 55, 56]. |

* [cite_start]**Colocar:** Haz clic en un ícono del panel y luego en el mapa[cite: 59, 60].
* [cite_start]**Mover:** Arrastra cualquier ícono directamente en el mapa[cite: 63].
* [cite_start]**Eliminar:** Haz clic derecho sobre el ícono que desees quitar[cite: 65].

## ⚙️ Toolbar y Comandos de Chat

### [cite_start]Botones de la Toolbar [cite: 66]
* [cite_start]`[ v Encounter ]`: Selección de mapa del encuentro[cite: 67].
* [cite_start]`[ Limpiar ]`: Elimina todos los iconos del mapa a la vez[cite: 67].
* [cite_start]`[ Sync ]`: Solicita al RL el estado actual del mapa (útil al reconectar)[cite: 67, 93].
* [cite_start]`[ Assist: ON/OFF ]`: Habilita que los asistentes puedan mover íconos[cite: 67].
* [cite_start]`[ X Cerrar ]`: Cierra la ventana[cite: 67].

### [cite_start]Comandos de Chat [cite: 68]
* [cite_start]`/rm`: Abre o cierra la ventana[cite: 74].
* [cite_start]`/rm map <key>`: Cambia el mapa directamente (Ej: `/rm map skeram`)[cite: 75].
* [cite_start]`/rm clear`: Limpia todos los íconos[cite: 76].
* [cite_start]`/rm assist on/off`: Controla si los asistentes pueden interactuar[cite: 77, 78].

## 🛡 Sistema de Permisos y Red
* [cite_start]**Raid Leader:** Control total sobre mapas, iconos y permisos[cite: 85].
* [cite_start]**Asistente:** Puede mover íconos solo si el RL activó la opción[cite: 86].
* [cite_start]**Miembro:** Solo visualización; no puede interactuar con el mapa[cite: 87].

[cite_start]La transmisión se realiza por el canal de **RAID/PARTY** con un throttle de 20 mensajes por segundo para prevenir lag[cite: 90, 91, 102].

## ❓ Solución de Problemas
* [cite_start]**Mapas en negro:** Borra el archivo `Cache.md5` en la carpeta de personaje dentro de `WTF`[cite: 96, 100].
* [cite_start]**No funciona:** El addon requiere estar en un grupo o raid; no funciona solo[cite: 103].
* [cite_start]**No aparece en la lista:** Verifica que la carpeta se llame exactamente `RaidMark`[cite: 107].

---
[cite_start]*RaidMark v0.23 - Hecho con ❤️ para raiders en Turtle WoW* [cite: 122, 123]
