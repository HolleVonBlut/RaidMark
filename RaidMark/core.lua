-- ============================================================
--  RaidMark -- core.lua
--  Estado global, inicializacion, eventos principales
-- ============================================================

RaidMark = {}
local RM = RaidMark

-- -- Version del protocolo de red --------------------------------
RM.VERSION      = "0.1"
RM.ADDON_PREFIX = "RaidMark"

-- -- Estado global -----------------------------------------------
RM.state = {
    -- Mapa activo (key de RaidMark_Maps)
    currentMap    = nil,

    -- Iconos colocados en el mapa
    -- { id, type, x, y, label }
    placedIcons   = {},

    -- Siguiente ID disponible para iconos
    nextIconId    = 1,

    -- Permisos: ?pueden los ASSIST mover iconos?
    assistCanMove = false,

    -- ?Esta el mapa visible?
    mapVisible    = false,
}

-- -- Constantes de tipos de icono --------------------------------
RM.ICON_TYPES = {
    "TANK",
    "HEALER",
    "DPS",
    "DPS_MELEE",
    "CASTER",
    "ARROW",
    "CIRCLE_S",
    "CIRCLE_M",
    "CIRCLE_L",
    "CIRCLE_XL",
    -- MEMBER_<name> se genera dinamicamente desde roster
}

-- Ruta base de texturas
RM.ICON_PATH = "Interface\\AddOns\\RaidMark\\icons\\"
RM.MAP_PATH  = "Interface\\AddOns\\RaidMark\\maps\\"

-- Textura para cada tipo de icono
RM.ICON_TEXTURE = {
    TANK      = RM.ICON_PATH .. "icon_tank",
    HEALER    = RM.ICON_PATH .. "icon_healer",
    DPS       = RM.ICON_PATH .. "icon_dps",
    DPS_MELEE = RM.ICON_PATH .. "icon_dps_melee",
    CASTER    = RM.ICON_PATH .. "icon_caster",
    ARROW     = RM.ICON_PATH .. "icon_arrow",
    CIRCLE_S  = RM.ICON_PATH .. "icon_circle_S",
    CIRCLE_M  = RM.ICON_PATH .. "icon_circle_M",
    CIRCLE_L  = RM.ICON_PATH .. "icon_circle_L",
    CIRCLE_XL = RM.ICON_PATH .. "icon_circle_XL",
    -- Clases pre-registradas para que funcionen al recibir via red/sync
    MEMBER_WARRIOR  = RM.ICON_PATH .. "icon_member_warrior",
    MEMBER_PALADIN  = RM.ICON_PATH .. "icon_member_paladin",
    MEMBER_HUNTER   = RM.ICON_PATH .. "icon_member_hunter",
    MEMBER_ROGUE    = RM.ICON_PATH .. "icon_member_rogue",
    MEMBER_PRIEST   = RM.ICON_PATH .. "icon_member_priest",
    MEMBER_SHAMAN   = RM.ICON_PATH .. "icon_member_shaman",
    MEMBER_MAGE     = RM.ICON_PATH .. "icon_member_mage",
    MEMBER_WARLOCK  = RM.ICON_PATH .. "icon_member_warlock",
    MEMBER_DRUID    = RM.ICON_PATH .. "icon_member_druid",
    MEMBER_UNKNOWN  = RM.ICON_PATH .. "icon_member_unknown",
}

-- Tamano en px de cada tipo en el mapa
RM.ICON_SIZE = {
    TANK      = 32,
    HEALER    = 32,
    DPS       = 32,
    DPS_MELEE = 32,
    CASTER    = 32,
    ARROW     = 28,
    CIRCLE_S  = 48,
    CIRCLE_M  = 80,
    CIRCLE_L  = 130,
    CIRCLE_XL = 180,
    -- Miembros
    MEMBER_WARRIOR  = 24,
    MEMBER_PALADIN  = 24,
    MEMBER_HUNTER   = 24,
    MEMBER_ROGUE    = 24,
    MEMBER_PRIEST   = 24,
    MEMBER_SHAMAN   = 24,
    MEMBER_MAGE     = 24,
    MEMBER_WARLOCK  = 24,
    MEMBER_DRUID    = 24,
    MEMBER_UNKNOWN  = 24,
}

-- -- Frame de eventos principal -----------------------------------
local eventFrame = CreateFrame("Frame", "RaidMarkEventFrame")

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
eventFrame:RegisterEvent("CHAT_MSG_ADDON")

eventFrame:SetScript("OnEvent", function()
    local event = event  -- vanilla usa global 'event'

    if event == "ADDON_LOADED" then
        if arg1 == "RaidMark" then
            RM.OnLoad()
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        RM.OnEnterWorld()

    elseif event == "RAID_ROSTER_UPDATE" or
           event == "PARTY_MEMBERS_CHANGED" then
        RM.Roster.Rebuild()

    elseif event == "CHAT_MSG_ADDON" then
        -- arg1=prefix, arg2=msg, arg3=channel, arg4=sender
        if arg1 == RM.ADDON_PREFIX then
            RM.Network.OnReceive(arg2, arg3, arg4)
        end
    end
end)

-- -- Inicializacion -----------------------------------------------
function RM.OnLoad()
    -- RegisterAddonMessagePrefix no existe en vanilla 1.12
    -- Los mensajes addon se reciben via CHAT_MSG_ADDON sin registro previo

    if not RaidMarkDB then
        RaidMarkDB = {}
    end

    DEFAULT_CHAT_FRAME:AddMessage("RaidMark DEBUG: MapFrame=" .. tostring(RM.MapFrame) .. " Icons=" .. tostring(RM.Icons))

    if RM.MapFrame and RM.MapFrame.Build then
        RM.MapFrame.Build()
        DEFAULT_CHAT_FRAME:AddMessage("RaidMark DEBUG: Build() ejecutado OK")
    else
        DEFAULT_CHAT_FRAME:AddMessage("RaidMark DEBUG: MapFrame.Build no encontrado")
    end

    DEFAULT_CHAT_FRAME:AddMessage(
        "RaidMark v" .. RM.VERSION .. " cargado. /rm para abrir."
    )
end

function RM.OnEnterWorld()
    RM.Roster.Rebuild()
end

-- -- Helpers globales --------------------------------------------

-- Genera un ID unico para iconos
function RM.NextId()
    local id = RM.state.nextIconId
    RM.state.nextIconId = id + 1
    return id
end

-- Limpia todo el estado de iconos
function RM.ClearAll()
    RM.state.placedIcons = {}
    RM.state.nextIconId  = 1
    if RM.Icons and RM.Icons.ClearAllFrames then
        RM.Icons.ClearAllFrames()
    end
end

-- Cambia el mapa activo
function RM.SetMap(mapKey)
    if not RaidMark_Maps or not RaidMark_Maps[mapKey] then
        DEFAULT_CHAT_FRAME:AddMessage("RaidMark: Mapa desconocido: " .. tostring(mapKey))
        return
    end
    RM.state.currentMap = mapKey
    if RM.MapFrame and RM.MapFrame.LoadMap then
        RM.MapFrame.LoadMap(mapKey)
    end
end

-- -- Comandos slash -----------------------------------------------
SLASH_RAIDMARK1 = "/raidmark"
SLASH_RAIDMARK2 = "/rm"

-- Helper seguro: llama funcion de MapFrame solo si ya existe
local function safeMapFrame(fn)
    if RM.MapFrame and RM.MapFrame[fn] then
        RM.MapFrame[fn]()
    else
        DEFAULT_CHAT_FRAME:AddMessage("RaidMark: UI no inicializada todavia.")
    end
end

SlashCmdList["RAIDMARK"] = function(msg)
    local cmd = string.lower(msg or "")

    if cmd == "" or cmd == "open" then
        safeMapFrame("Toggle")

    elseif cmd == "close" then
        safeMapFrame("Hide")

    elseif cmd == "clear" then
        if RM.Permissions.CanPlace() then
            RM.ClearAll()
            RM.Network.SendClear()
        else
            DEFAULT_CHAT_FRAME:AddMessage("RaidMark: No tenes permisos para limpiar.")
        end

    elseif string.sub(cmd, 1, 4) == "map " then
        local mapKey = string.sub(cmd, 5)
        if RM.Permissions.CanPlace() then
            RM.SetMap(mapKey)
            RM.Network.SendMapChange(mapKey)
        else
            DEFAULT_CHAT_FRAME:AddMessage("RaidMark: Solo el RL puede cambiar el mapa.")
        end

    elseif cmd == "assist on" then
        if RM.Permissions.IsRL() then
            RM.state.assistCanMove = true
            RM.Network.SendPermissions(true)
            DEFAULT_CHAT_FRAME:AddMessage("RaidMark: Asistentes pueden mover iconos.")
        end

    elseif cmd == "assist off" then
        if RM.Permissions.IsRL() then
            RM.state.assistCanMove = false
            RM.Network.SendPermissions(false)
            DEFAULT_CHAT_FRAME:AddMessage("RaidMark: Solo el RL puede mover iconos.")
        end

    else
        DEFAULT_CHAT_FRAME:AddMessage("RaidMark comandos:")
        DEFAULT_CHAT_FRAME:AddMessage("  /rm           -- abrir/cerrar mapa")
        DEFAULT_CHAT_FRAME:AddMessage("  /rm map <key> -- cambiar mapa (twin_emperors, cthun_normal, cthun_stomach)")
        DEFAULT_CHAT_FRAME:AddMessage("  /rm clear     -- limpiar todos los iconos")
        DEFAULT_CHAT_FRAME:AddMessage("  /rm assist on/off -- permisos de asistentes")
    end
end
