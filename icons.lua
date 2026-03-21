-- ============================================================
--  RaidMark -- icons.lua
--  Sistema de iconos arrastrables sobre el mapa
-- ============================================================

local RM = RaidMark
RM.Icons = {}
local IC = RM.Icons

-- -- Contador de frames creados en la sesion (para aviso de memoria) --
-- Solo cuenta frames de iconos del lienzo, no UI frames del panel
IC.frameCount = 0

-- -- Pool de frames de iconos activos ----------------------------
-- [iconId] = frame
IC.activeFrames = {}


local function GetScaledCursor()
    local x, y = GetCursorPosition()
    local s = RaidMarkMainFrame:GetEffectiveScale()
    return x/s, y/s
end



-- -- Crear un frame de icono sobre el mapa -----------------------

-- ============================================================
--  Sistema de flechas direccionales con hitbox y stretch
--  Para ARROW_N, ARROW_S, ARROW_E, ARROW_O
--  - La textura (256x256) se muestra centrada en la posicion
--  - Un cuadrado verde (hitbox) exactamente en el centro es
--    lo UNICO interactuable: drag, rueda del mouse
--  - Rueda del mouse: estira la textura en su eje principal
--    ARROW_E / ARROW_O -> stretch horizontal (ancho)
--    ARROW_N / ARROW_S -> stretch vertical (alto)
-- ============================================================

local ARROW_TEX_BASE  = 104   -- tamaño base de la textura (igual que ICON_SIZE)
local ARROW_HITBOX    = 16    -- tamaño del cuadrado hitbox en el centro
local ARROW_STRETCH_STEP = 10  -- px por tick de rueda
local ARROW_STRETCH_MIN  = ARROW_TEX_BASE
local ARROW_STRETCH_MAX  = 400

-- Tipos horizontales (stretch en ancho)
local ARROW_HORIZONTAL = { ARROW_E=true, ARROW_O=true }
-- Tipos verticales (stretch en alto)
local ARROW_VERTICAL   = { ARROW_N=true, ARROW_S=true }
-- Tipos diagonales (scale uniforme)
local ARROW_DIAGONAL   = { ARROW_NE=true, ARROW_NO=true, ARROW_SE=true, ARROW_SO=true }

local function isArrowType(t)
    return t=="ARROW_N" or t=="ARROW_S" or t=="ARROW_E" or t=="ARROW_O"
        or t=="ARROW_NE" or t=="ARROW_NO" or t=="ARROW_SE" or t=="ARROW_SO"
end

local function createArrowFrame(iconId, iconType, x, y)
    local mapFrame = RM.MapFrame.contentFrame
    local mapW     = mapFrame:GetWidth()
    local mapH     = mapFrame:GetHeight()
    local baseSize = RM.ICON_SIZE[iconType] or ARROW_TEX_BASE
    local texPath  = RM.ICON_TEXTURE[iconType]

    -- Estado de stretch almacenado en el frame
    local stretchW = baseSize
    local stretchH = baseSize

    -- Contenedor principal (invisible, solo agrupa hitbox + textura)
    IC.frameCount = IC.frameCount + 3  -- container + texFrame + hitbox
    local container = CreateFrame("Frame", "RaidMarkArrow_"..iconId, mapFrame)
    container:SetWidth(1)
    container:SetHeight(1)
    container:SetPoint("CENTER", mapFrame, "TOPLEFT", x * mapW, -y * mapH)
    container:SetFrameLevel(mapFrame:GetFrameLevel() + 2)

    -- Textura de la flecha (no interactuable, size dinamico)
    local texFrame = CreateFrame("Frame", nil, container)
    texFrame:SetWidth(stretchW)
    texFrame:SetHeight(stretchH)
    texFrame:SetPoint("CENTER", container, "CENTER", 0, 0)
    texFrame:SetFrameLevel(container:GetFrameLevel())
    texFrame:EnableMouse(false)
    local tex = texFrame:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(texFrame)
    tex:SetTexture(texPath)
    -- Aplicar tinte de color si fue guardado al colocar
    local data0 = RM.state.placedIcons[iconId]
    if data0 and data0.colorR then
        tex:SetVertexColor(data0.colorR, data0.colorG, data0.colorB)
    end

    -- Hitbox: cuadrado verde interactuable en el centro
    local hitbox = CreateFrame("Button", nil, container)
    hitbox:SetWidth(ARROW_HITBOX)
    hitbox:SetHeight(ARROW_HITBOX)
    hitbox:SetPoint("CENTER", container, "CENTER", 0, 0)
    hitbox:SetFrameLevel(container:GetFrameLevel() + 3)
    hitbox:EnableMouse(true)
    hitbox:RegisterForClicks("RightButtonUp")
    hitbox:RegisterForDrag("LeftButton")

    -- Visual del hitbox (cuadrado verde semitransparente)
    local hbTex = hitbox:CreateTexture(nil, "ARTWORK")
    hbTex:SetAllPoints(hitbox)
    hbTex:SetTexture(0.1, 0.9, 0.1, 0.55)
    -- Borde del hitbox
    local hbBorder = hitbox:CreateTexture(nil, "OVERLAY")
    hbBorder:SetAllPoints(hitbox)
    hbBorder:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")

    -- Highlight al pasar el mouse
    local hl = hitbox:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints(hitbox)
    hl:SetTexture(1, 1, 1, 0.3)

    -- Funcion para actualizar el tamaño de la textura
    local function applyStretch()
        texFrame:SetWidth(stretchW)
        texFrame:SetHeight(stretchH)
        -- Guardar en estado y broadcastear
        local data = RM.state.placedIcons[iconId]
        if data then
            data.stretchW = stretchW
            data.stretchH = stretchH
        end
        RM.Network.SendStretch(iconId, stretchW, stretchH)
    end

    -- Rueda del mouse: stretch en eje principal
    hitbox:EnableMouseWheel(true)
    hitbox:SetScript("OnMouseWheel", function()
        if not RM.Permissions.CanPlace() then return end
        local delta = arg1  -- vanilla: arg1 es el delta de la rueda
        if ARROW_DIAGONAL[iconType] then
            -- Diagonales: escala uniforme (W y H juntos)
            local newSize = math.max(ARROW_STRETCH_MIN, math.min(ARROW_STRETCH_MAX, stretchW + delta * ARROW_STRETCH_STEP))
            stretchW = newSize
            stretchH = newSize
        elseif ARROW_HORIZONTAL[iconType] then
            stretchW = math.max(ARROW_STRETCH_MIN, math.min(ARROW_STRETCH_MAX, stretchW + delta * ARROW_STRETCH_STEP))
        else
            stretchH = math.max(ARROW_STRETCH_MIN, math.min(ARROW_STRETCH_MAX, stretchH + delta * ARROW_STRETCH_STEP))
        end
        applyStretch()
    end)

    -- Clic derecho: eliminar
    hitbox:SetScript("OnClick", function()
        if IsAltKeyDown() then return end
        if RM.Permissions.CanPlace() then
            RM.Network.SendRemove(iconId)
            IC.ApplyRemove(iconId)
        else
            UIErrorsFrame:AddMessage("No tienes permisos.", 1, 0.3, 0.3, 1, 3)
        end
    end)

    -- Drag: mover por el lienzo
    hitbox:SetMovable(false)
    container:SetMovable(true)

    hitbox:SetScript("OnDragStart", function()
        if IsAltKeyDown() then return end
        if not RM.Permissions.CanPlace() then
            UIErrorsFrame:AddMessage("No tienes permisos.", 1, 0.3, 0.3, 1, 3)
            return
        end
        container:StartMoving()
        container.isDragging = true
    end)

    hitbox:SetScript("OnDragStop", function()
        if not container.isDragging then return end
        container:StopMovingOrSizing()
        container.isDragging = false

        local mLeft = mapFrame:GetLeft()
        local mTop  = mapFrame:GetTop()
        local mW    = mapFrame:GetWidth()
        local mH    = mapFrame:GetHeight()
        local cx    = container:GetLeft() + container:GetWidth()  / 2
        local cy    = container:GetTop()  - container:GetHeight() / 2

        local nx = math.max(0, math.min(1, (cx - mLeft) / mW))
        local ny = math.max(0, math.min(1, (mTop - cy)  / mH))

        container:ClearAllPoints()
        container:SetPoint("CENTER", mapFrame, "TOPLEFT", nx * mW, -ny * mH)

        RM.state.placedIcons[iconId].x = nx
        RM.state.placedIcons[iconId].y = ny
        RM.Network.SendMove(iconId, nx, ny)
    end)

    -- Tooltip
    hitbox:SetScript("OnEnter", function()
        local data = RM.state.placedIcons[iconId]
        if not data then return end
        GameTooltip:SetOwner(hitbox, "ANCHOR_RIGHT")
        GameTooltip:SetText(data.iconType)
        GameTooltip:AddLine("Rueda: estirar  |  Drag: mover  |  Clic derecho: eliminar", 0.7,0.7,0.7,true)
        GameTooltip:Show()
    end)
    hitbox:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Restaurar stretch si ya tenia datos guardados
    local data = RM.state.placedIcons[iconId]
    if data then
        if data.stretchW then stretchW = data.stretchW end
        if data.stretchH then stretchH = data.stretchH end
        applyStretch()
    end

    container.texFrame = texFrame
    container.hitbox   = hitbox
    return container
end

local function createIconFrame(iconId, iconType, x, y, label)
    -- Delegamos flechas direccionales a su sistema propio
    if isArrowType(iconType) then
        return createArrowFrame(iconId, iconType, x, y)
    end

    local mapFrame  = RM.MapFrame.contentFrame
    local mapW      = RM.MapFrame.contentFrame:GetWidth()
    local mapH      = RM.MapFrame.contentFrame:GetHeight()
    local size      = RM.ICON_SIZE[iconType] or 32
    local texPath   = RM.ICON_TEXTURE[iconType]

    -- Frame contenedor
    IC.frameCount = IC.frameCount + 1  -- 1 frame por icono normal
    local f = CreateFrame("Button", "RaidMarkIcon_" .. iconId, mapFrame)
    f:SetWidth(size)
    f:SetHeight(size)
    -- Fakes offline en nivel bajo para que raiders reales queden siempre encima
    if RM.IsOfflineRoleIcon and RM.IsOfflineRoleIcon(iconType) then
        f:SetFrameLevel(mapFrame:GetFrameLevel() + 1)
    else
        f:SetFrameLevel(mapFrame:GetFrameLevel() + 2)
    end

    -- Posicionar en coordenadas normalizadas (0-1)
    f:SetPoint("CENTER", mapFrame, "TOPLEFT",
               x * mapW,
               -y * mapH)

-- Textura
    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(f)
    tex:SetTexture(texPath)
    -- Iconos offline: cuadrado de color solido directo
    if RM.OFFLINE_ICON_COLOR and RM.OFFLINE_ICON_COLOR[iconType] then
        local oc = RM.OFFLINE_ICON_COLOR[iconType]
        tex:SetTexture(oc[1], oc[2], oc[3], oc[4] or 1)
    end

    -- FIX: Aplicar el recorte para mostrar solo el icono (calavera, cruz, etc.)
    local tc = RM.ICON_TEXCOORD and RM.ICON_TEXCOORD[iconType]
    if tc then
        tex:SetTexCoord(tc[1], tc[2], tc[3], tc[4])
    end
    -- Label debajo del icono (para iconos de miembro)
    if label and label ~= "" then
        local fs = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("TOP", f, "BOTTOM", 0, -2)
        fs:SetText(label)
        fs:SetTextColor(1, 1, 1, 0.9)
        f.labelText = fs
    end

-- Boton derecho para eliminar (solo si tiene permisos)
    f:RegisterForClicks("RightButtonUp")
    f:SetScript("OnClick", function()
        -- SEGURO: Si ALT está presionado, ignoramos la interacción con el icono
        if IsAltKeyDown() then return end
        
        if RM.Permissions.CanPlace() then
            RM.Network.SendRemove(iconId)
            IC.ApplyRemove(iconId)
        else
            UIErrorsFrame:AddMessage("No tienes permisos. No eres RL ni Asistente.", 1, 0.3, 0.3, 1, 3)
        end
    end)

    -- -- Drag & Drop ---------------------------------------------
    f:RegisterForDrag("LeftButton")

    f:SetScript("OnDragStart", function()
        if IsAltKeyDown() then return end
        -- Fakes solo movibles en modo offline
        if RM.IsOfflineRoleIcon and RM.IsOfflineRoleIcon(iconType) and not RM.state.offlineMode then
            if RM.MapFrame and RM.MapFrame.ConsoleMsg then
                RM.MapFrame.ConsoleMsg("Solo movibles en Modo Offline.", 1, 0.5, 0.1)
            end
            return
        end
        if not RM.Permissions.CanPlace() then
            UIErrorsFrame:AddMessage("No tienes permisos. No eres RL ni Asistente.", 1, 0.3, 0.3, 1, 3)
            return
        end
        f:StartMoving()
        f.isDragging = true
    end)

    f:SetScript("OnDragStop", function()
        if not f.isDragging then return end
        f:StopMovingOrSizing()
        f.isDragging = false

        -- Calcular nueva posicion normalizada
        local mLeft   = mapFrame:GetLeft()
        local mTop    = mapFrame:GetTop()
        local mW      = mapFrame:GetWidth()
        local mH      = mapFrame:GetHeight()
        local fCX     = f:GetLeft() + f:GetWidth()  / 2
        local fCY     = f:GetTop()  - f:GetHeight() / 2

        local nx = (fCX - mLeft) / mW
        local ny = (mTop - fCY)  / mH

        -- Clampear dentro del mapa
        nx = math.max(0, math.min(1, nx))
        ny = math.max(0, math.min(1, ny))

        -- Re-anclar limpio
        f:ClearAllPoints()
        f:SetPoint("CENTER", mapFrame, "TOPLEFT",
                   nx * mW, -ny * mH)

        -- Actualizar estado local
        RM.state.placedIcons[iconId].x = nx
        RM.state.placedIcons[iconId].y = ny

        -- Broadcastear (throttled)
        RM.Network.SendMove(iconId, nx, ny)
    end)

    -- Tooltip al hacer hover
    f:SetScript("OnEnter", function()
        local data = RM.state.placedIcons[iconId]
        if not data then return end
        GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
        GameTooltip:SetText(data.iconType .. (data.label ~= "" and (" -- " .. data.label) or ""))
        GameTooltip:AddLine("Click derecho para eliminar", 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)

    f:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    f:SetMovable(true)
    f:EnableMouse(true)

    return f
end

-- -- Helper: ¿Está el jugador ya en el lienzo? --------------------
function IC.IsPlayerPlaced(name)
    if not name or name == "" then return false end
    for _, data in pairs(RM.state.placedIcons) do
        if data.label == name then return true end
    end
    return false
end

-- -- API: Aplicar colocacion (desde red o local) ------------------
function IC.ApplyPlace(iconId, iconType, x, y, label, colorR, colorG, colorB, stretchW, stretchH)
    -- Guardar en estado
    RM.state.placedIcons[iconId] = {
        id       = iconId,
        iconType = iconType,
        x        = x,
        y        = y,
        label    = label or "",
        colorR   = colorR,
        colorG   = colorG,
        colorB   = colorB,
        stretchW = (stretchW and stretchW > 0) and stretchW or nil,
        stretchH = (stretchH and stretchH > 0) and stretchH or nil,
    }

    -- Actualizar nextIconId si hace falta
    if iconId >= RM.state.nextIconId then
        RM.state.nextIconId = iconId + 1
    end

    -- Crear frame si el mapa esta visible (saltar si esta marcado como hidden)
    if RM.MapFrame.contentFrame and RM.MapFrame.contentFrame:IsVisible() then
        if IC.activeFrames[iconId] then
            IC.activeFrames[iconId]:Hide()
        end
        if not RM.state.placedIcons[iconId].hidden then
            IC.activeFrames[iconId] = createIconFrame(iconId, iconType, x, y, label)
        end
    end

    -- Refrescar la lista lateral
    if RM.MapFrame and RM.MapFrame.RebuildRosterButtons then
        RM.MapFrame.RebuildRosterButtons()
    end
end

-- -- API: Aplicar movimiento --------------------------------------
function IC.ApplyStretch(iconId, sw, sh)
    local data = RM.state.placedIcons[iconId]
    if not data then return end
    data.stretchW = sw
    data.stretchH = sh
    local f = IC.activeFrames[iconId]
    if f and f.texFrame then
        f.texFrame:SetWidth(sw)
        f.texFrame:SetHeight(sh)
    end
end

function IC.ApplyMove(iconId, x, y)
    local data = RM.state.placedIcons[iconId]
    if not data then return end

    data.x = x
    data.y = y

    local f = IC.activeFrames[iconId]
    if f then
        local mW = RM.MapFrame.contentFrame:GetWidth()
        local mH = RM.MapFrame.contentFrame:GetHeight()
        f:ClearAllPoints()
        f:SetPoint("CENTER", RM.MapFrame.contentFrame, "TOPLEFT",
                   x * mW, -y * mH)
    end
end

-- -- API: Aplicar eliminacion -------------------------------------
function IC.ApplyRemove(iconId)
    RM.state.placedIcons[iconId] = nil

    local f = IC.activeFrames[iconId]
    if f then
        f:Hide()
        IC.activeFrames[iconId] = nil
    end

    -- Refrescar la lista lateral
    if RM.MapFrame and RM.MapFrame.RebuildRosterButtons then
        RM.MapFrame.RebuildRosterButtons()
    end
end
-- -- Limpiar todos los frames -------------------------------------
function IC.ClearAllFrames()
    for id, f in pairs(IC.activeFrames) do
        f:Hide()
    end
    IC.activeFrames = {}
end

-- -- Redibujar todos los iconos (al abrir el mapa) ----------------
function IC.RedrawAll()
    IC.ClearAllFrames()
    for iconId, data in pairs(RM.state.placedIcons) do
        if not data.hidden then
            IC.activeFrames[iconId] = createIconFrame(
                iconId, data.iconType, data.x, data.y, data.label
            )
        end
    end
end

-- -- Colocar icono desde el panel (accion del RL) -----------------
-- x, y son coords normalizadas en el mapa (0-1)
function IC.PlaceNew(iconType, x, y, label, colorR, colorG, colorB)
    if not RM.Permissions.CanPlace() then return end

    local iconId = RM.NextId()
    label = label or ""

    -- Aplicar localmente
    IC.ApplyPlace(iconId, iconType, x, y, label, colorR, colorG, colorB)

    -- Broadcastear (stretch=0 al colocar, se actualiza via SendStretch al estirar)
    local d = RM.state.placedIcons[iconId]
    RM.Network.SendPlace(iconId, iconType, x, y, label,
        colorR, colorG, colorB, 0, 0)
end

-- -- Reconstruir panel lateral de miembros -----------------------
-- Se llama desde roster.lua cuando el raid cambia
function IC.RebuildRosterPanel()
    if RM.MapFrame and RM.MapFrame.RebuildRosterButtons then
        RM.MapFrame.RebuildRosterButtons()
    end
end
