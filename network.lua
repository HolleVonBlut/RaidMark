-- ============================================================
--  RaidMark -- network.lua
--  Envio y recepcion de mensajes. Throttling incluido.
-- ============================================================

local RM = RaidMark
RM.Network = {}
local N = RM.Network

-- -- Configuracion -----------------------------------------------
local SEND_INTERVAL = 0.05   -- 20 msgs/seg maximo por icono arrastrado
local MSG_SEP       = ";"   -- separador de campos (NO usar | que WoW interpreta como color code)

-- -- Cola de envio (throttling) ----------------------------------
-- Guardamos el ultimo mensaje por iconId para evitar flood
-- Solo enviamos el mas reciente si el timer lo permite
local pendingMoves   = {}   -- [iconId] = {x, y}
local timeSinceSend  = 0
local throttleFrame  = CreateFrame("Frame", "RaidMarkThrottleFrame")

throttleFrame:SetScript("OnUpdate", function()
    timeSinceSend = timeSinceSend + arg1

    if timeSinceSend < SEND_INTERVAL then return end
    timeSinceSend = 0

    -- Vaciar cola de movimientos pendientes
    for iconId, pos in pairs(pendingMoves) do
        N.SendRaw("MOVE" .. MSG_SEP .. iconId .. MSG_SEP
                         .. string.format("%.4f", pos.x) .. MSG_SEP
                         .. string.format("%.4f", pos.y))
    end
    pendingMoves = {}
end)

-- -- Canal de envio -----------------------------------------------
local function getChannel()
    if GetNumRaidMembers() > 0 then
        return "RAID"
    elseif GetNumPartyMembers() > 0 then
        return "PARTY"
    end
    -- Solo para pruebas en solitario
    return "WHISPER"
end

function N.SendRaw(msg)
    local channel = getChannel()
    if channel == "WHISPER" then return end  -- sin grupo, no enviamos nada
    SendAddonMessage(RM.ADDON_PREFIX, msg, channel)
end

-- -- API publica de envio -----------------------------------------

-- Colocar un icono nuevo
function N.SendPlace(iconId, iconType, x, y, label)
    label = label or ""
    N.SendRaw("PLACE" .. MSG_SEP .. iconId .. MSG_SEP
                      .. iconType .. MSG_SEP
                      .. string.format("%.4f", x) .. MSG_SEP
                      .. string.format("%.4f", y) .. MSG_SEP
                      .. label)
end

-- Mover icono (throttled -- encola en vez de enviar directo)
function N.SendMove(iconId, x, y)
    pendingMoves[iconId] = { x = x, y = y }
end

-- Eliminar icono
function N.SendRemove(iconId)
    pendingMoves[iconId] = nil
    N.SendRaw("REMOVE" .. MSG_SEP .. iconId)
end

-- Limpiar todo
function N.SendClear()
    pendingMoves = {}
    N.SendRaw("CLEAR")
end

-- Cambiar mapa
function N.SendMapChange(mapKey)
    N.SendRaw("MAP" .. MSG_SEP .. mapKey)
end

-- Cambiar permisos de asistentes
function N.SendPermissions(assistCanMove)
    local val = assistCanMove and "1" or "0"
    N.SendRaw("PERMS" .. MSG_SEP .. val)
end

-- Pedir sincronizacion al RL (cualquiera puede pedirlo)
function N.SendSyncRequest()
    N.SendRaw("SYNC_REQ")
    DEFAULT_CHAT_FRAME:AddMessage("RaidMark: Solicitando sincronizacion...")
end

-- RL responde con estado completo a todo el raid
function N.SendSyncResponse()
    -- Primero el mapa actual
    if RM.state.currentMap then
        N.SendRaw("MAP" .. MSG_SEP .. RM.state.currentMap)
    end
    -- Luego los permisos
    local val = RM.state.assistCanMove and "1" or "0"
    N.SendRaw("PERMS" .. MSG_SEP .. val)
    -- Luego cada icono colocado
    for iconId, data in pairs(RM.state.placedIcons) do
        N.SendRaw("PLACE" .. MSG_SEP .. iconId .. MSG_SEP
                          .. data.iconType .. MSG_SEP
                          .. string.format("%.4f", data.x) .. MSG_SEP
                          .. string.format("%.4f", data.y) .. MSG_SEP
                          .. (data.label or ""))
    end
    DEFAULT_CHAT_FRAME:AddMessage("RaidMark: Estado sincronizado enviado.")
end

-- -- Recepcion ---------------------------------------------------
function N.OnReceive(msg, channel, sender)
    -- Ignorar mensajes propios
    if sender == UnitName("player") then return end

    -- Parsear primero para conocer el comando
    local parts = {}
    for part in string.gfind(msg, "([^" .. MSG_SEP .. "]+)") do
        table.insert(parts, part)
    end
    if not parts[1] then return end
    local cmd = parts[1]

    -- SYNC_REQ: cualquier miembro puede pedirlo, solo el RL responde
    if cmd == "SYNC_REQ" then
        if RM.Permissions.IsRL() then
            N.SendSyncResponse()
        end
        return
    end

    -- El resto de comandos requieren que el sender sea RL o Assist autorizado
    if not RM.Permissions.SenderCanControl(sender) then return end

    -- -- PLACE ---------------------------------------------------
    if cmd == "PLACE" then
        local iconId   = tonumber(parts[2])
        local iconType = parts[3]
        local x        = tonumber(parts[4])
        local y        = tonumber(parts[5])
        local label    = parts[6] or ""
        if iconId and iconType and x and y then
            RM.Icons.ApplyPlace(iconId, iconType, x, y, label)
        end

    -- -- MOVE ----------------------------------------------------
    elseif cmd == "MOVE" then
        local iconId = tonumber(parts[2])
        local x      = tonumber(parts[3])
        local y      = tonumber(parts[4])
        if iconId and x and y then
            RM.Icons.ApplyMove(iconId, x, y)
        end

    -- -- REMOVE --------------------------------------------------
    elseif cmd == "REMOVE" then
        local iconId = tonumber(parts[2])
        if iconId then
            RM.Icons.ApplyRemove(iconId)
        end

    -- -- CLEAR ---------------------------------------------------
    elseif cmd == "CLEAR" then
        if not RM.Permissions.SenderIsRL(sender) then return end
        RM.ClearAll()

    -- -- MAP -----------------------------------------------------
    elseif cmd == "MAP" then
        if not RM.Permissions.SenderIsRL(sender) then return end
        local mapKey = parts[2]
        if mapKey then
            RM.state.currentMap = mapKey
            RM.MapFrame.LoadMap(mapKey)
        end

    -- -- PERMS ---------------------------------------------------
    elseif cmd == "PERMS" then
        if not RM.Permissions.SenderIsRL(sender) then return end
        RM.state.assistCanMove = (parts[2] == "1")
        RM.MapFrame.UpdateAssistBtn()
    end
end
