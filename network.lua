-- ============================================================
--  RaidMark -- network.lua
--  Envio y recepcion de mensajes. Throttling incluido.
-- ============================================================

local RM = RaidMark
RM.Network = {}
local N = RM.Network

-- -- Configuracion -----------------------------------------------
local SEND_INTERVAL = 0.033   -- 20 msgs/seg maximo por icono arrastrado
local MSG_SEP       = ";"   -- separador de campos (NO usar | que WoW interpreta como color code)

-- -- Cola de envio (throttling) ----------------------------------
local pendingMoves     = {}
local timeSinceSend    = 0
local throttleFrame    = CreateFrame("Frame", "RaidMarkThrottleFrame")

-- Throttle separado para el puntero (100ms = 10 msgs/seg)
local ptrTimeSinceSend = 0
local PTR_INTERVAL     = 0.033

throttleFrame:SetScript("OnUpdate", function()
    local dt = arg1
    timeSinceSend    = timeSinceSend    + dt
    ptrTimeSinceSend = ptrTimeSinceSend + dt

    -- Flush cola de movimientos de iconos
    if timeSinceSend >= SEND_INTERVAL then
        timeSinceSend = 0
        for iconId, pos in pairs(pendingMoves) do
            N.SendRaw("MOVE" .. MSG_SEP .. iconId .. MSG_SEP
                             .. string.format("%.4f", pos.x) .. MSG_SEP
                             .. string.format("%.4f", pos.y))
        end
        pendingMoves = {}
    end

    -- Flush puntero (250ms)
    if ptrTimeSinceSend >= PTR_INTERVAL then
        ptrTimeSinceSend = 0
        if RM.state.pointerActive
           and not RM.state.pointerMouseBtn
           and RM.state.myPointerSlot then
            if RM.MapFrame and RM.MapFrame.GetPointerPos then
                local px, py = RM.MapFrame.GetPointerPos()
                if px and py then
                    local slot = RM.state.pointerSlots[RM.state.myPointerSlot]
                    N.SendRaw("PTR" .. MSG_SEP .. slot.color .. MSG_SEP
                                    .. string.format("%.4f", px) .. MSG_SEP
                                    .. string.format("%.4f", py))
                end
            end
        end
    end
end)

-- -- Canal de envio -----------------------------------------------
local function getChannel()
    if GetNumRaidMembers() > 0 then
        return "RAID"
    elseif GetNumPartyMembers() > 0 then
        return "PARTY"
    end
    return "WHISPER"
end

function N.SendRaw(msg)
    -- Bloquear todo en modo offline
    if RM.Network.IsOffline and RM.Network.IsOffline() then return end
    local channel = getChannel()
    if channel == "WHISPER" then return end
    SendAddonMessage(RM.ADDON_PREFIX, msg, channel)
end

-- -- API publica de envio -----------------------------------------

function N.SendPlace(iconId, iconType, x, y, label, colorR, colorG, colorB, stretchW, stretchH)
    -- IMPORTANTE: usar "_" como placeholder de label vacio
    -- string.gfind con ([^;]+) omite campos vacios, desplazando indices de color
    local safeLabel = (label and label ~= "") and label or "_"
    colorR   = colorR   or 1
    colorG   = colorG   or 1
    colorB   = colorB   or 1
    stretchW = stretchW or 0
    stretchH = stretchH or 0
    N.SendRaw("PLACE" .. MSG_SEP .. iconId .. MSG_SEP
                      .. iconType .. MSG_SEP
                      .. string.format("%.4f", x) .. MSG_SEP
                      .. string.format("%.4f", y) .. MSG_SEP
                      .. safeLabel .. MSG_SEP
                      .. string.format("%.3f", colorR) .. MSG_SEP
                      .. string.format("%.3f", colorG) .. MSG_SEP
                      .. string.format("%.3f", colorB) .. MSG_SEP
                      .. stretchW .. MSG_SEP
                      .. stretchH)
end

function N.SendMove(iconId, x, y)
    pendingMoves[iconId] = { x = x, y = y }
end

function N.SendStretch(iconId, stretchW, stretchH)
    N.SendRaw("STRETCH" .. MSG_SEP .. iconId .. MSG_SEP .. stretchW .. MSG_SEP .. stretchH)
end

function N.SendRemove(iconId)
    pendingMoves[iconId] = nil
    N.SendRaw("REMOVE" .. MSG_SEP .. iconId)
end

function N.SendClear()
    pendingMoves = {}
    N.SendRaw("CLEAR")
end

-- Enviar asignacion de rol de un raider al grupo
function N.SendRole(playerName, role)
    if not playerName or playerName == "" then return end
    local roleStr = role or "NONE"
    N.SendRaw("ROLE" .. MSG_SEP .. playerName .. MSG_SEP .. roleStr)
end

-- Enviar todos los roles con micro-delay para no saturar canal
function N.SendAllRoles()
    if not RM.state.memberRoles then return end
    local queue = {}
    for name, role in pairs(RM.state.memberRoles) do
        if name and name ~= "" and role then
            table.insert(queue, {name=name, role=role})
        end
    end
    if table.getn(queue) == 0 then return end
    local idx = 1
    local elapsed = 0
    local roleFrame = CreateFrame("Frame","RaidMarkRoleSync")
    roleFrame:SetScript("OnUpdate", function()
        elapsed = elapsed + arg1
        if elapsed >= 0.1 then
            elapsed = 0
            if idx <= table.getn(queue) then
                local entry = queue[idx]
                N.SendRaw("ROLE"..MSG_SEP..entry.name..MSG_SEP..entry.role)
                idx = idx + 1
            else
                roleFrame:SetScript("OnUpdate",nil)
            end
        end
    end)
end

function N.SendMapChange(mapKey)
    N.SendRaw("MAP" .. MSG_SEP .. mapKey)
end

function N.SendPermissions(assistCanMove)
    local val = assistCanMove and "1" or "0"
    N.SendRaw("PERMS" .. MSG_SEP .. val)
end

function N.SendVersion()
    local channel = getChannel()
    if channel == "WHISPER" then return end
    N.SendRaw("VER" .. MSG_SEP .. tostring(RM.VERSION_NUM))
end

function N.SendPointerRelease()
    if RM.state.myPointerSlot then
        local slot = RM.state.pointerSlots[RM.state.myPointerSlot]
        N.SendRaw("PTR_REL" .. MSG_SEP .. slot.color)
    end
end

function N.SendPointerClaim(colorName)
    N.SendRaw("PTR_CLAIM" .. MSG_SEP .. colorName)
end

function N.SendPointerClear()
    N.SendRaw("PTR_CLEAR")
end

function N.SendSyncRequest()
    N.SendRaw("SYNC_REQ")
    if RM.MapFrame and RM.MapFrame.ConsoleMsg then RM.MapFrame.ConsoleMsg("Solicitando sync...", 0.4,0.8,1) end
end

-- Estado del sync en progreso
N.syncInProgress = false

function N.SendSyncResponse()
    if N.syncInProgress then return end  -- evitar spam

    -- Recopilar iconos a enviar (excluir fakes y hidden)
    local toSend = {}
    for iconId, data in pairs(RM.state.placedIcons) do
        if not (RM.IsOfflineRoleIcon and RM.IsOfflineRoleIcon(data.iconType))
           and not data.hidden then
            table.insert(toSend, {id=iconId, data=data})
        end
    end
    local total = table.getn(toSend)

    -- Elegir delay segun tabla
    local delay
    if     total <= 10 then delay = 0
    elseif total <= 25 then delay = 0.05
    elseif total <= 50 then delay = 0.15
    else                    delay = 0.2
    end

    -- Enviar CLEAR + MAP + PERMS inmediatamente
    N.SendRaw("CLEAR")
    if RM.state.currentMap then
        N.SendRaw("MAP" .. MSG_SEP .. RM.state.currentMap)
    end
    local val = RM.state.assistCanMove and "1" or "0"
    N.SendRaw("PERMS" .. MSG_SEP .. val)

    if total == 0 then
        if RM.MapFrame and RM.MapFrame.ConsoleMsg then
            RM.MapFrame.ConsoleMsg("Sync enviado.", 0.4,1,0.4)
        end
        return
    end

    -- Bloquear boton Sync y moves durante el envio
    N.syncInProgress = true
    local savedMoves  = pendingMoves
    pendingMoves      = {}   -- pausar moves

    if RM.MapFrame and RM.MapFrame.syncBtn then
        RM.MapFrame.syncBtn:SetAlpha(0.4)
        RM.MapFrame.syncBtn:EnableMouse(false)
    end

    -- Envio con delay usando OnUpdate
    local idx      = 1
    local elapsed  = 0
    local sentSoFar = 0
    local animPhase = 0
    local animTimer = 0
    local animFrames = {
        "Sync [.       ] 0%",
        "Sync [==      ]",
        "Sync [====    ]",
        "Sync [======  ]",
        "Sync [========]",
    }

    local syncFrame = CreateFrame("Frame","RaidMarkSyncProgress")
    syncFrame:SetScript("OnUpdate", function()
        local dt = arg1

        -- Actualizar barra de progreso en box (cada 1 segundo)
        animTimer = animTimer + dt
        if animTimer >= 1.0 then
            animTimer = 0
            animPhase = math.mod(animPhase, 4) + 1
            local pct  = math.floor(sentSoFar / total * 100 + 0.5)
            local bars  = math.floor(pct / 12.5 + 0.5)  -- 0-8 barras
            local filled = string.rep("=", bars)
            local empty  = string.rep(" ", 8 - bars)
            local msg    = "Sync ["..filled..empty.."] "..pct.."%"
            if RM.MapFrame and RM.MapFrame.ConsoleMsg then
                RM.MapFrame.ConsoleMsg(msg, 0.4, 0.8, 1)
            end
        end

        -- Si no hay delay, enviar todos de golpe en este frame
        if delay == 0 then
            for _, entry in ipairs(toSend) do
                local data = entry.data
                local cr = data.colorR or 1; local cg = data.colorG or 1
                local cb = data.colorB or 1; local sw = data.stretchW or 0
                local sh = data.stretchH or 0
                N.SendRaw("PLACE"..MSG_SEP..entry.id..MSG_SEP..data.iconType..MSG_SEP
                    ..string.format("%.4f",data.x)..MSG_SEP..string.format("%.4f",data.y)..MSG_SEP
                    ..((data.label and data.label~="") and data.label or "_")..MSG_SEP
                    ..string.format("%.3f",cr)..MSG_SEP..string.format("%.3f",cg)..MSG_SEP
                    ..string.format("%.3f",cb)..MSG_SEP..sw..MSG_SEP..sh)
            end
            sentSoFar = total
            idx = total + 1
        else
            -- Envio con delay
            elapsed = elapsed + dt
            if elapsed >= delay and idx <= total then
                elapsed = 0
                local entry = toSend[idx]
                local data  = entry.data
                local cr = data.colorR or 1; local cg = data.colorG or 1
                local cb = data.colorB or 1; local sw = data.stretchW or 0
                local sh = data.stretchH or 0
                N.SendRaw("PLACE"..MSG_SEP..entry.id..MSG_SEP..data.iconType..MSG_SEP
                    ..string.format("%.4f",data.x)..MSG_SEP..string.format("%.4f",data.y)..MSG_SEP
                    ..((data.label and data.label~="") and data.label or "_")..MSG_SEP
                    ..string.format("%.3f",cr)..MSG_SEP..string.format("%.3f",cg)..MSG_SEP
                    ..string.format("%.3f",cb)..MSG_SEP..sw..MSG_SEP..sh)
                idx        = idx + 1
                sentSoFar  = sentSoFar + 1
            end
        end

        -- Fin del envio
        if idx > total then
            syncFrame:SetScript("OnUpdate", nil)
            N.syncInProgress = false
            -- Restaurar moves pausados
            for k,v in pairs(savedMoves) do pendingMoves[k] = v end
            -- Restaurar boton Sync
            if RM.MapFrame and RM.MapFrame.syncBtn then
                RM.MapFrame.syncBtn:SetAlpha(1.0)
                RM.MapFrame.syncBtn:EnableMouse(true)
            end
            if RM.MapFrame and RM.MapFrame.ConsoleMsg then
                RM.MapFrame.ConsoleMsg("Sync enviado ("..total.." iconos).", 0.4,1,0.4)
            end
        end
    end)
end

-- NUEVA FUNCION: Enviar lista de miembros
function N.SendRosterSync()
    -- FORZAR rebuild fresco desde WoW antes de enviar
    RM.Roster.Rebuild()
    
    local count = 0
    for _ in pairs(RM.Roster.members) do count = count + 1 end
    if count == 0 then return end
    
    local memberList = {}
    for name, data in pairs(RM.Roster.members) do
        table.insert(memberList, name .. ":" .. (data.classFile or "UNKNOWN") .. ":" .. (data.rank or 0))
    end
    
    N.SendRaw("ROSTER_START" .. MSG_SEP .. count)
    
    for _, memberStr in ipairs(memberList) do
        N.SendRaw("ROSTER_ADD" .. MSG_SEP .. memberStr)
    end
    
    if RM.MapFrame and RM.MapFrame.ConsoleMsg then RM.MapFrame.ConsoleMsg("Roster sync: "..count.." miembros.", 0.4,1,0.6) end
end

-- -- Recepcion ---------------------------------------------------
function N.OnReceive(msg, channel, sender)
    if sender == UnitName("player") then return end

    local parts = {}
    for part in string.gfind(msg, "([^" .. MSG_SEP .. "]+)") do
        table.insert(parts, part)
    end
    if not parts[1] then return end
    local cmd = parts[1]

    -- SYNC_REQ
    if cmd == "SYNC_REQ" then
        if RM.Permissions.IsRL() then
            N.SendSyncResponse()
            N.SendRosterSync()
        end
        return
    end

    -- ROSTER_START
    if cmd == "ROSTER_START" then
        RM.Roster.members = {}
        return
    end
    
  -- ROSTER_ADD
    if cmd == "ROSTER_ADD" then
        local memberStr = parts[2]
        if memberStr then
            -- Manual parse porque strsplit no existe en Lua 5.0 (Vanilla)
            local name, classFile, rank
            local firstColon = string.find(memberStr, ":")
            local secondColon = string.find(memberStr, ":", firstColon + 1)
            
            if firstColon and secondColon then
                name = string.sub(memberStr, 1, firstColon - 1)
                classFile = string.sub(memberStr, firstColon + 1, secondColon - 1)
                rank = string.sub(memberStr, secondColon + 1)
            elseif firstColon then
                name = string.sub(memberStr, 1, firstColon - 1)
                classFile = string.sub(memberStr, firstColon + 1)
                rank = "0"
            else
                name = memberStr
                classFile = "UNKNOWN"
                rank = "0"
            end
            
            if name and name ~= "" then
                RM.Roster.members[name] = {
                    name = name,
                    classFile = classFile or "UNKNOWN",
                    rank = tonumber(rank) or 0,
                }
            end
        end
        return
    end

    if not RM.Permissions.SenderCanControl(sender) then return end

    if cmd == "PLACE" then
        if RM.state.offlineMode then return end  -- ignorar en modo offline
        local iconId   = tonumber(parts[2])
        local iconType = parts[3]
        local x        = tonumber(parts[4])
        local y        = tonumber(parts[5])
        local rawLabel = parts[6] or "_"
        local label    = (rawLabel == "_") and "" or rawLabel
        local colorR   = tonumber(parts[7]) or 1
        local colorG   = tonumber(parts[8]) or 1
        local colorB   = tonumber(parts[9]) or 1
        local stretchW = tonumber(parts[10]) or 0
        local stretchH = tonumber(parts[11]) or 0
        if iconId and iconType and x and y then
            RM.Icons.ApplyPlace(iconId, iconType, x, y, label, colorR, colorG, colorB, stretchW, stretchH)
        end

    elseif cmd == "MOVE" then
        if RM.state.offlineMode then return end
        local iconId = tonumber(parts[2])
        local x      = tonumber(parts[3])
        local y      = tonumber(parts[4])
        if iconId and x and y then
            RM.Icons.ApplyMove(iconId, x, y)
        end

    elseif cmd == "STRETCH" then
        if RM.state.offlineMode then return end
        local iconId   = tonumber(parts[2])
        local stretchW = tonumber(parts[3])
        local stretchH = tonumber(parts[4])
        if iconId and stretchW and stretchH then
            RM.Icons.ApplyStretch(iconId, stretchW, stretchH)
        end

    elseif cmd == "REMOVE" then
        if RM.state.offlineMode then return end
        local iconId = tonumber(parts[2])
        if iconId then
            RM.Icons.ApplyRemove(iconId)
        end

    elseif cmd == "CLEAR" then
        if not RM.Permissions.SenderIsRL(sender) then return end
        if RM.state.offlineMode then return end  -- ignorar en modo offline
        RM.ClearAll()

    elseif cmd == "MAP" then
        if not RM.Permissions.SenderIsRL(sender) then return end
        if RM.state.offlineMode then return end  -- ignorar en modo offline
        local mapKey = parts[2]
        if mapKey then
            RM.state.currentMap = mapKey
            if RM.MapFrame and RM.MapFrame.LoadMap then RM.MapFrame.LoadMap(mapKey) end
        end

    elseif cmd == "PERMS" then
        if not RM.Permissions.SenderIsRL(sender) then return end
        RM.state.assistCanMove = (parts[2] == "1")
        if RM.MapFrame and RM.MapFrame.UpdateAssistBtn then RM.MapFrame.UpdateAssistBtn() end

    elseif cmd == "ROLE" then
        -- Solo aceptar roles del RL
        if not RM.Permissions.SenderIsRL(sender) then return end
        if RM.state.offlineMode then return end
        local playerName = parts[2]
        local role       = parts[3]
        if playerName and playerName ~= "" then
            if role == "NONE" or role == "" or role == nil then
                RM.state.memberRoles[playerName] = nil
            else
                RM.state.memberRoles[playerName] = role
            end
            if RaidMarkDB then RaidMarkDB.memberRoles = RM.state.memberRoles end
            if RM.MapFrame and RM.MapFrame.RebuildRosterButtons then
                RM.MapFrame.RebuildRosterButtons()
            end
        end

    elseif cmd == "ROLEPROPOSE" then
        -- Assist propone roles al RL: solo rellena huecos (no sobreescribe)
        if not RM.Permissions.IsRL() then return end
        if RM.state.offlineMode then return end
        -- Formato: ROLEPROPOSE;nombre;rol (separado por MSG_SEP como el resto)
        local pName = parts[2]
        local pRole = parts[3]
        if pName and pRole and pName ~= "" and pRole ~= "" then
            -- Solo aplicar si el raider NO tiene rol asignado aun
            if not RM.state.memberRoles[pName] then
                RM.state.memberRoles[pName] = pRole
                if RaidMarkDB then RaidMarkDB.memberRoles = RM.state.memberRoles end
                if RM.MapFrame and RM.MapFrame.RebuildRosterButtons then
                    RM.MapFrame.RebuildRosterButtons()
                end
            end
        end

    elseif cmd == "ASSIGN_COOLDOWN" then
        -- Bloquear localmente por la duracion indicada
        local duration = tonumber(parts[2]) or 10
        if RM.MapFrame and RM.MapFrame.SetAssignCooldown then
            RM.MapFrame.SetAssignCooldown(duration)
        end

    elseif cmd == "VER" then
        local theirVer = tonumber(parts[2]) or 0
        if theirVer > RM.VERSION_NUM then
            local msg = "ALERTA: " .. sender .. " tiene RaidMark v?" ..
                        parts[2] .. " (tu tienes v" .. RM.VERSION ..
                        "). Actualiza en github o contacta a 'holle'."
            if RM.MapFrame and RM.MapFrame.ConsoleMsg then
                RM.MapFrame.ConsoleMsg(msg, 1, 0.4, 0.1)
            end
        end

    elseif cmd == "PTR" then
        local colorName = parts[2]
        local px        = tonumber(parts[3])
        local py        = tonumber(parts[4])
        if colorName and px and py then
            if RM.MapFrame and RM.MapFrame.AddRemotePointerDot then
                RM.MapFrame.AddRemotePointerDot(sender, colorName, px, py)
            end
        end

    elseif cmd == "PTR_CLAIM" then
        local colorName = parts[2]
        for i, slot in ipairs(RM.state.pointerSlots) do
            if slot.color == colorName and not slot.owner then
                slot.owner = sender
                if RM.MapFrame and RM.MapFrame.UpdatePointerSlotUI then
                    RM.MapFrame.UpdatePointerSlotUI()
                end
                break
            end
        end

    elseif cmd == "PTR_REL" then
        local colorName = parts[2]
        for i, slot in ipairs(RM.state.pointerSlots) do
            if slot.color == colorName and slot.owner == sender then
                slot.owner = nil
                slot.lastX = nil
                slot.lastY = nil
                if RM.MapFrame and RM.MapFrame.UpdatePointerSlotUI then
                    RM.MapFrame.UpdatePointerSlotUI()
                end
                break
            end
        end

    elseif cmd == "PTR_CLEAR" then
        if not RM.Permissions.SenderIsRL(sender) then return end
        for i = 2, 4 do
            RM.state.pointerSlots[i].owner = nil
        end
        local mySlot = RM.state.myPointerSlot
        if mySlot and mySlot > 1 then
            if RM.MapFrame and RM.MapFrame.SetPointerActive then
                RM.MapFrame.SetPointerActive(false)
            end
        end
        if RM.MapFrame and RM.MapFrame.UpdatePointerSlotUI then
            RM.MapFrame.UpdatePointerSlotUI()
        end
    end
end