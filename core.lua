-- ============================================================
--  RaidMark -- core.lua
--  Estado global, inicializacion, eventos principales
-- ============================================================

RaidMark = {}
local RM = RaidMark

-- Mensaje: intenta el box informativo, sino va al chat
function RM.Msg(text, r, g, b)
    if RM.MapFrame and RM.MapFrame.ConsoleMsg then
        RM.MapFrame.ConsoleMsg(text, r or 0.7, g or 0.9, b or 1)
    else
        DEFAULT_CHAT_FRAME:AddMessage("RaidMark: " .. text)
    end
end

RM.VERSION      = "1.5"
RM.VERSION_NUM  = 10
RM.ADDON_PREFIX = "RaidMark"

RM.state = {
    currentMap    = nil,
    placedIcons   = {},
    memberRoles   = {},   -- [playerName] = "TANK"|"DPS_M"|"DPS_R"|"HEAL"
    nextIconId    = 1,
    assistCanMove = false,
    mapVisible    = false,
    currentScale  = 1.0,
currentLayer  = 1,
    pointerSlots = {
        { color = "RED",    r=1,   g=0.1, b=0.1, owner=nil, lastX=nil, lastY=nil },
        { color = "BLUE",   r=0.3, g=0.5, b=1,   owner=nil, lastX=nil, lastY=nil },
        { color = "GREEN",  r=0.2, g=0.9, b=0.2, owner=nil, lastX=nil, lastY=nil },
        { color = "YELLOW", r=1,   g=0.9, b=0.1, owner=nil, lastX=nil, lastY=nil },
    },
myPointerSlot   = nil,
    pointerActive   = false,
    pointerMouseBtn = false,
}

RM.ICON_TYPES = {
    "TANK", "HEALER", "DPS", "DPS_MELEE", "CASTER", "ARROW",
    "ARROW_N", "ARROW_S", "ARROW_E", "ARROW_O",
    "ARROW_NE", "ARROW_NO", "ARROW_SE", "ARROW_SO",
    "CIRCLE_S", "CIRCLE_M", "CIRCLE_L", "CIRCLE_XL",
    "SKULL1", "SKULL2", "SKULL3",
    "MARK_STAR", "MARK_CIRCLE", "MARK_DIAMOND", "MARK_TRIANGLE",
    "MARK_MOON", "MARK_SQUARE", "MARK_CROSS", "MARK_SKULL",
}

RM.ICON_PATH = "Interface\\AddOns\\RaidMark\\icons\\"
RM.MAP_PATH  = "Interface\\AddOns\\RaidMark\\maps\\"

RM.ICON_TEXTURE = {
    TANK      = RM.ICON_PATH .. "icon_tank",
    HEALER    = RM.ICON_PATH .. "icon_healer",
    DPS       = RM.ICON_PATH .. "icon_dps",
    DPS_MELEE = RM.ICON_PATH .. "icon_dps_melee",
    CASTER    = RM.ICON_PATH .. "icon_caster",
    ARROW     = RM.ICON_PATH .. "icon_arrow",
    ARROW_N   = RM.ICON_PATH .. "arrow_N",
    ARROW_S   = RM.ICON_PATH .. "arrow_S",
    ARROW_E   = RM.ICON_PATH .. "arrow_E",
    ARROW_O   = RM.ICON_PATH .. "arrow_O",
    ARROW_NE  = RM.ICON_PATH .. "arrow_NE",
    ARROW_NO  = RM.ICON_PATH .. "arrow_NO",
    ARROW_SE  = RM.ICON_PATH .. "arrow_SE",
    ARROW_SO  = RM.ICON_PATH .. "arrow_SO",
    CIRCLE_S  = RM.ICON_PATH .. "icon_circle_S",
    CIRCLE_M  = RM.ICON_PATH .. "icon_circle_M",
    CIRCLE_L  = RM.ICON_PATH .. "icon_circle_L",
    CIRCLE_XL = RM.ICON_PATH .. "icon_circle_XL",
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
    SKULL1    = "Interface\\Icons\\Ability_Rogue_Ambush",
    SKULL2    = "Interface\\Icons\\Spell_Shadow_DeathCoil",
    SKULL3    = "Interface\\Icons\\Ability_Racial_Undead",
    MARK_STAR     = "Interface\\TargetingFrame\\UI-RaidTargetingIcons",
    MARK_CIRCLE   = "Interface\\TargetingFrame\\UI-RaidTargetingIcons",
    MARK_DIAMOND  = "Interface\\TargetingFrame\\UI-RaidTargetingIcons",
    MARK_TRIANGLE = "Interface\\TargetingFrame\\UI-RaidTargetingIcons",
    MARK_MOON     = "Interface\\TargetingFrame\\UI-RaidTargetingIcons",
    MARK_SQUARE   = "Interface\\TargetingFrame\\UI-RaidTargetingIcons",
    MARK_CROSS    = "Interface\\TargetingFrame\\UI-RaidTargetingIcons",
    MARK_SKULL    = "Interface\\TargetingFrame\\UI-RaidTargetingIcons",
}

RM.ICON_SIZE = {
    TANK      = 42,  HEALER = 42,  DPS    = 42,
    DPS_MELEE = 42,  CASTER = 42,  ARROW  = 36,
    CIRCLE_S  = 62,  CIRCLE_M = 104, CIRCLE_L = 169, CIRCLE_XL = 234,
    ARROW_N = 104, ARROW_S = 104, ARROW_E = 104, ARROW_O = 104,
    ARROW_NE = 104, ARROW_NO = 104, ARROW_SE = 104, ARROW_SO = 104,
    MEMBER_WARRIOR = 31, MEMBER_PALADIN = 31, MEMBER_HUNTER = 31,
    MEMBER_ROGUE   = 31, MEMBER_PRIEST  = 31, MEMBER_SHAMAN = 31,
    MEMBER_MAGE    = 31, MEMBER_WARLOCK = 31, MEMBER_DRUID  = 31,
    MEMBER_UNKNOWN = 31,
    SKULL1 = 62,  SKULL2 = 62,  SKULL3 = 62,
    MARK_STAR=53,  MARK_CIRCLE=53,  MARK_DIAMOND=53,  MARK_TRIANGLE=53,
    MARK_MOON=53,  MARK_SQUARE=53,  MARK_CROSS=53,    MARK_SKULL=53,
}

RM.ICON_TEXCOORD = {
    SKULL1 = {0.0781, 0.9219, 0.0781, 0.9219},
    SKULL2 = {0.0781, 0.9219, 0.0781, 0.9219},
    SKULL3 = {0.0781, 0.9219, 0.0781, 0.9219},
    MARK_STAR     = {0.0000, 0.2500, 0.0000, 0.2500},
    MARK_CIRCLE   = {0.2500, 0.5000, 0.0000, 0.2500},
    MARK_DIAMOND  = {0.5000, 0.7500, 0.0000, 0.2500},
    MARK_TRIANGLE = {0.7500, 1.0000, 0.0000, 0.2500},
    MARK_MOON     = {0.0000, 0.2500, 0.2500, 0.5000},
    MARK_SQUARE   = {0.2500, 0.5000, 0.2500, 0.5000},
    MARK_CROSS    = {0.5000, 0.7500, 0.2500, 0.5000},
    MARK_SKULL    = {0.7500, 1.0000, 0.2500, 0.5000},
}

local eventFrame = CreateFrame("Frame", "RaidMarkEventFrame")

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
eventFrame:RegisterEvent("CHAT_MSG_ADDON")

eventFrame:SetScript("OnEvent", function()
    local event = event

    if event == "ADDON_LOADED" then
        if arg1 == "RaidMark" then
            RM.OnLoad()
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        RM.OnEnterWorld()

    elseif event == "RAID_ROSTER_UPDATE" or
           event == "PARTY_MEMBERS_CHANGED" then
        RM.Roster.Rebuild()
        RM.ValidatePointerSlots()
        -- NUEVO: Si soy RL, envio roster automaticamente
        if RM.Permissions.IsRL() then
            RM.Network.SendRosterSync()
        end

    elseif event == "CHAT_MSG_ADDON" then
        if arg1 == RM.ADDON_PREFIX then
            RM.Network.OnReceive(arg2, arg3, arg4)
        end
    end
end)

function RM.OnLoad()
    if not RaidMarkDB then
        RaidMarkDB = {}
    end
    -- Restaurar roles guardados
    if RaidMarkDB.memberRoles then
        RM.state.memberRoles = RaidMarkDB.memberRoles
    else
        RaidMarkDB.memberRoles = RM.state.memberRoles
    end

    if RM.MapFrame and RM.MapFrame.Build then
        RM.MapFrame.Build()
    end

    DEFAULT_CHAT_FRAME:AddMessage(
        "RaidMark v" .. RM.VERSION .. " cargado. /rm para abrir."
    )

    -- Broadcast de version
    local vDelay = CreateFrame("Frame")
    local vTimer = 0
    vDelay:SetScript("OnUpdate", function()
        vTimer = vTimer + arg1
        if vTimer >= 3 then
            RM.Network.SendVersion()
            vDelay:SetScript("OnUpdate", nil)
        end
    end)
    
    -- NUEVO: Solicitar sync al inicio
    local rosterSyncTimer = 0
    local rosterSyncFrame = CreateFrame("Frame")
    rosterSyncFrame:SetScript("OnUpdate", function()
        rosterSyncTimer = rosterSyncTimer + arg1
        if rosterSyncTimer >= 2 then
            RM.Network.SendSyncRequest()
            rosterSyncFrame:SetScript("OnUpdate", nil)
        end
    end)
end

function RM.OnEnterWorld()
    RM.Roster.Rebuild()
    -- Si el jugador es RL al entrar al mundo, activar Assist:ON automaticamente
    -- Usamos un pequeno delay para asegurar que el roster este listo
    local initFrame = CreateFrame("Frame")
    local initTimer = 0
    initFrame:SetScript("OnUpdate", function()
        initTimer = initTimer + arg1
        if initTimer >= 2 then  -- esperar 2s para que el roster cargue
            initFrame:SetScript("OnUpdate", nil)
            if RM.Permissions.IsRL() and not RM.state.assistCanMove then
                RM.state.assistCanMove = true
                -- Broadcast si estamos en raid
                if GetNumRaidMembers() > 0 or GetNumPartyMembers() > 0 then
                    RM.Network.SendPermissions(true)
                end
                -- Actualizar boton del widget si esta abierto
                if RM.Widget and RM.Widget.updateAssistBtn then
                    RM.Widget.updateAssistBtn()
                end
            end
        end
    end)
end

function RM.NextId()
    local id = RM.state.nextIconId
    RM.state.nextIconId = id + 1
    return id
end

function RM.ValidatePointerSlots()
    local myName = UnitName("player")
    local changed = false

    local function isInRaid(name)
        if GetNumRaidMembers() > 0 then
            for i = 1, 40 do
                local n = GetRaidRosterInfo(i)
                if n == name then return true end
            end
        else
            if UnitName("player") == name then return true end
            for i = 1, GetNumPartyMembers() do
                if UnitName("party"..i) == name then return true end
            end
        end
        return false
    end

    for i, slot in ipairs(RM.state.pointerSlots) do
        if slot.owner and not isInRaid(slot.owner) then
            slot.owner = nil
            changed = true
            if RM.state.myPointerSlot == i then
                if RM.MapFrame and RM.MapFrame.SetPointerActive then
                    RM.MapFrame.SetPointerActive(false)
                end
            end
        end
    end

    local mySlot = RM.state.myPointerSlot
    if mySlot == 1 and not RM.Permissions.IsRL() then
        RM.state.pointerSlots[1].owner = nil
        if RM.MapFrame and RM.MapFrame.SetPointerActive then
            RM.MapFrame.SetPointerActive(false)
        end
        changed = true
    end

    if changed and RM.MapFrame and RM.MapFrame.UpdatePointerSlotUI then
        RM.MapFrame.UpdatePointerSlotUI()
    end
end

function RM.ClearAll()
    RM.state.placedIcons   = {}   -- limpia TODOS (incluye fakes hidden)
    RM.state.nextIconId    = 1
    RM.state.lastLoadedPosi = nil  -- limpiar flag de posicionamiento
    if RM.Icons and RM.Icons.ClearAllFrames then
        RM.Icons.ClearAllFrames()
    end
end

function RM.SetMap(mapKey)
    if not RaidMark_Maps or not RaidMark_Maps[mapKey] then
        RM.Msg("Mapa desconocido: " .. tostring(mapKey), 1, 0.5, 0.2)
        return
    end
    RM.state.currentMap = mapKey
    if RM.MapFrame and RM.MapFrame.LoadMap then
        RM.MapFrame.LoadMap(mapKey)
    end
end

SLASH_RAIDMARK1 = "/raidmark"
SLASH_RAIDMARK2 = "/rm"

local function safeMapFrame(fn)
    if RM.MapFrame and RM.MapFrame[fn] then
        RM.MapFrame[fn]()
    else
        RM.Msg("UI no inicializada todavia.", 1, 0.6, 0.2)
    end
end

SlashCmdList["RAIDMARK"] = function(msg)
    local cmd = string.lower(msg or "")

    if cmd == "" or cmd == "open" then
        safeMapFrame("Toggle")

    elseif cmd == "r" or cmd == "rc" or cmd == "readycheck" then
        -- Ready Check Remoto
        if RM.Consumables and RM.Consumables.SendReadyCheckRequest then
            RM.Consumables.SendReadyCheckRequest()
        else
            RM.Msg("Panel de consumibles no inicializado. Abre /rm primero.", 1, 0.5, 0.2)
        end

    elseif cmd == "w" or cmd == "widget" then
        if RM.Widget then
            RM.Widget.Toggle()
        else
            RM.Msg("Widget no disponible.", 1, 0.5, 0.2)
        end

    elseif cmd == "rcdebug" then
        -- Activa un frame que logea TODOS los CHAT_MSG_SYSTEM durante 30 segundos
        -- Util para encontrar el texto exacto de los mensajes de RC en Turtle WoW
        RM.Msg("RC Debug ACTIVADO - logea CHAT_MSG_SYSTEM por 30s.", 0.5, 1, 0.5)
        local rcDebugFrame = CreateFrame("Frame","RaidMarkRCDebug")
        rcDebugFrame:RegisterEvent("CHAT_MSG_SYSTEM")
        local elapsed = 0
        rcDebugFrame:SetScript("OnEvent",function()
            DEFAULT_CHAT_FRAME:AddMessage("|cffff9900[RCDebug SYSTEM]|r " .. tostring(arg1))
        end)
        rcDebugFrame:SetScript("OnUpdate",function()
            elapsed = elapsed + arg1
            if elapsed >= 30 then
                rcDebugFrame:UnregisterAllEvents()
                rcDebugFrame:SetScript("OnUpdate",nil)
                rcDebugFrame:SetScript("OnEvent",nil)
                RM.Msg("RC Debug desactivado.", 0.5, 0.5, 0.5)
            end
        end)

    elseif cmd == "close" then
        safeMapFrame("Hide")

    elseif cmd == "clear" then
        if RM.Permissions.CanPlace() then
            RM.ClearAll()
            RM.Network.SendClear()
        else
            RM.Msg("Sin permisos para limpiar.", 1, 0.3, 0.3)
        end

    elseif string.sub(cmd, 1, 4) == "map " then
        local mapKey = string.sub(cmd, 5)
        if RM.Permissions.CanPlace() then
            RM.SetMap(mapKey)
            RM.Network.SendMapChange(mapKey)
        else
            RM.Msg("Solo el RL puede cambiar el mapa.", 1, 0.4, 0.2)
        end

    elseif cmd == "assist on" then
        if RM.Permissions.IsRL() then
            RM.state.assistCanMove = true
            RM.Network.SendPermissions(true)
            RM.Msg("Assist: ON — pueden mover iconos.", 0.3, 1, 0.4)
        end

    elseif cmd == "assist off" then
        if RM.Permissions.IsRL() then
            RM.state.assistCanMove = false
            RM.Network.SendPermissions(false)
            RM.Msg("Assist: OFF — solo el RL mueve.", 0.7, 0.7, 0.7)
        end

    elseif cmd == "buffdebug" then
        -- DEBUG: Imprime en el chat todos los buffs del jugador actual
        -- Usar: /rm buffdebug
        DEFAULT_CHAT_FRAME:AddMessage("|cffff9900[RaidMark BuffDebug] Buffs de: " .. UnitName("player") .. "|r")
        local i = 1
        local found = 0
        while true do
            local bname, brank, btex = UnitBuff("player", i)
            if not bname then break end
            local texStr = btex or "nil"
            -- Calcular nombre normalizado para comparar contra la tabla
            local normName = string.lower(texStr)
            local lastSep = 0
            for pos = 1, string.len(normName) do
                local ch = string.sub(normName, pos, pos)
                if ch == "\\" or ch == "/" then lastSep = pos end
            end
            local baseName = string.sub(normName, lastSep + 1)
            local dot = 0
            for pos = 1, string.len(baseName) do
                if string.sub(baseName, pos, pos) == "." then dot = pos end
            end
            if dot > 0 then baseName = string.sub(baseName, 1, dot - 1) end
            DEFAULT_CHAT_FRAME:AddMessage(
                "|cffffff00[" .. i .. "]|r tex: " .. texStr ..
                " |cff88ff88-> norm: " .. baseName .. "|r"
            )
            found = found + 1
            i = i + 1
        end
        if found == 0 then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff4444[RaidMark] No se encontraron buffs en 'player'.|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cff44ff44[RaidMark] Total: " .. found .. " buffs.|r")
        end

    elseif string.sub(cmd, 1, 10) == "buffdebug " then
        -- DEBUG con unit especifica: /rm buffdebug raid1
        local unit = string.sub(cmd, 11)
        DEFAULT_CHAT_FRAME:AddMessage("|cffff9900[RaidMark BuffDebug] Buffs de unit: " .. unit .. "|r")
        if not UnitExists(unit) then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff4444Unit no existe: " .. unit .. "|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffaaaaaa Nombre: " .. (UnitName(unit) or "?") .. "|r")
            local i = 1
            local found = 0
            while true do
                local bname, brank, btex = UnitBuff(unit, i)
                if not bname then break end
                DEFAULT_CHAT_FRAME:AddMessage(
                    "|cffffff00[" .. i .. "]|r " ..
                    tostring(bname) .. " | tex: " .. tostring(btex)
                )
                found = found + 1
                i = i + 1
            end
            DEFAULT_CHAT_FRAME:AddMessage("|cff44ff44Total: " .. found .. " buffs.|r")
        end

    elseif cmd == "rabdebug" then
        -- DEBUG: Prueba RAB_CallRaidBuffCheck con mageblood y muestra el resultado raw
        -- Uso: /rm rabdebug
        DEFAULT_CHAT_FRAME:AddMessage("|cffff9900[RaidMark RABdebug]|r Verificando RABuffs...")
        if not RAB_Buffs then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff4444RAB_Buffs es nil - RABuffs no esta cargado.|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cff44ff44RAB_Buffs encontrado.|r")
        end
        if not RAB_CallRaidBuffCheck then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff4444RAB_CallRaidBuffCheck es nil - funcion no disponible.|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cff44ff44RAB_CallRaidBuffCheck encontrado.|r")
            -- Verificar identifiers de keys clave
            local testKeys = { "mageblood", "flask", "giants", "spiritofzanza" }
            for _, tkey in ipairs(testKeys) do
                if RAB_Buffs[tkey] then
                    local ids = RAB_Buffs[tkey].identifiers
                    if ids and type(ids) == "table" then
                        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00" .. tkey .. ": " .. table.getn(ids) .. " identifier(s)|r")
                        for ii, id in ipairs(ids) do
                            local s = string.lower(id.texture or "")
                            local lastSep = 0
                            for pos = 1, string.len(s) do
                                local ch = string.sub(s, pos, pos)
                                if ch == "\\" or ch == "/" then lastSep = pos end
                            end
                            DEFAULT_CHAT_FRAME:AddMessage("  tex_norm=" .. string.sub(s, lastSep+1))
                        end
                    else
                        DEFAULT_CHAT_FRAME:AddMessage("|cffff8800" .. tkey .. ": identifiers vacio|r")
                    end
                else
                    DEFAULT_CHAT_FRAME:AddMessage("|cff888888'" .. tkey .. "' NO en RAB_Buffs|r")
                end
            end
            -- Mostrar buffs activos del jugador
            DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Buffs activos (texturas normalizadas):|r")
            local bi = 1
            while true do
                local btex = UnitBuff("player", bi)
                if not btex then break end
                local s = string.lower(btex)
                local lastSep = 0
                for pos = 1, string.len(s) do
                    local ch = string.sub(s, pos, pos)
                    if ch == "\\" or ch == "/" then lastSep = pos end
                end
                DEFAULT_CHAT_FRAME:AddMessage("  [" .. bi .. "] " .. string.sub(s, lastSep+1))
                bi = bi + 1
            end
        end

    elseif cmd == "rabkeys" then
        -- DEBUG: Lista las primeras keys de RAB_Buffs para verificar nombres exactos
        -- Uso: /rm rabkeys
        if not RAB_Buffs then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff4444RAB_Buffs no encontrado.|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffff9900[RABkeys] Primeras keys en RAB_Buffs:|r")
            local count = 0
            for k, v in pairs(RAB_Buffs) do
                count = count + 1
                if count <= 30 then
                    DEFAULT_CHAT_FRAME:AddMessage("  " .. tostring(k) .. " = " .. tostring(v.name or "?"))
                end
            end
            DEFAULT_CHAT_FRAME:AddMessage("Total keys: " .. count)
        end

        DEFAULT_CHAT_FRAME:AddMessage("RaidMark comandos:")
        DEFAULT_CHAT_FRAME:AddMessage("  /rm           -- abrir/cerrar mapa")
        DEFAULT_CHAT_FRAME:AddMessage("  /rm map <key> -- cambiar mapa")
        DEFAULT_CHAT_FRAME:AddMessage("  /rm clear     -- limpiar todos los iconos")
        DEFAULT_CHAT_FRAME:AddMessage("  /rm assist on/off -- permisos de asistentes")
        DEFAULT_CHAT_FRAME:AddMessage("  /rm buffdebug      -- listar tus buffs actuales")
        DEFAULT_CHAT_FRAME:AddMessage("  /rm buffdebug raid1 -- listar buffs de raid1")
        DEFAULT_CHAT_FRAME:AddMessage("  /rm rabdebug       -- probar RAB_CallRaidBuffCheck")
        DEFAULT_CHAT_FRAME:AddMessage("  /rm rabkeys        -- listar keys de RAB_Buffs")
        DEFAULT_CHAT_FRAME:AddMessage("  /rm r              -- Ready Check Remoto")
        DEFAULT_CHAT_FRAME:AddMessage("  /rm w              -- Toggle widget flotante")
        DEFAULT_CHAT_FRAME:AddMessage("  /rm rcdebug        -- Activar log de CHAT_MSG_SYSTEM (debug RC)")
    end
end
