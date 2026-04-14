-- ============================================================
--  RaidMark -- mapframe.lua
--  Frame principal del mapa tactico con toolbar y panel lateral
-- ============================================================

-- Debug: verificar que RaidMark existe
if not RaidMark then
    DEFAULT_CHAT_FRAME:AddMessage("RaidMark ERROR: RaidMark global es nil en mapframe.lua")
end

local RM = RaidMark
RM.MapFrame = {}
local MF = RM.MapFrame

-- Fuente +15% para labels y botones
local function BigFont(fs, base)
    fs:SetFont("Fonts\\FRIZQT__.TTF", math.floor(base * 1.15 + 0.5), "")
end
local function BigFontOutline(fs, base)
    fs:SetFont("Fonts\\FRIZQT__.TTF", math.floor(base * 1.15 + 0.5), "OUTLINE")
end


-- -- Dimensiones (+50%) --------------------------------------------
local MAP_W         = 1365  -- +30% sobre 1050
local MAP_H         = 768   -- +30% sobre 591
local TOOLBAR_H     = 48
local PANEL_W       = 312   -- +30% sobre 240
local TOTAL_W       = MAP_W + PANEL_W
local TOTAL_H       = MAP_H + TOOLBAR_H + 30  -- +30 titlebar

-- -- Crear el frame principal -------------------------------------
local mainFrame = CreateFrame("Frame", "RaidMarkMainFrame", UIParent)
mainFrame:SetWidth(TOTAL_W)
mainFrame:SetHeight(TOTAL_H)
mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
-- Restaurar posicion y escala guardadas (se sobreescribe en MF.Build si hay datos)
mainFrame:SetFrameStrata("HIGH")
mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", function() mainFrame:StartMoving() end)
mainFrame:SetScript("OnDragStop", function()
    mainFrame:StopMovingOrSizing()
    -- Persistir posicion
    if RaidMarkDB then
        local point, _, relPoint, x, y = mainFrame:GetPoint()
        RaidMarkDB.savedX     = x
        RaidMarkDB.savedY     = y
        RaidMarkDB.savedPoint = point
    end
end)
mainFrame:Hide()

-- Fondo principal
local bg = mainFrame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(mainFrame)
bg:SetTexture(0.05, 0.05, 0.08, 0.95)

-- Borde
local border = CreateFrame("Frame", nil, mainFrame)
border:SetAllPoints(mainFrame)
border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets   = { left=3, right=3, top=3, bottom=3 },
})
border:SetBackdropBorderColor(0.4, 0.35, 0.2, 1)

-- -- Title bar ---------------------------------------------------
local titleBar = CreateFrame("Frame", nil, mainFrame)
titleBar:SetWidth(TOTAL_W)
titleBar:SetHeight(30)
titleBar:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, 0)

local titleBg = titleBar:CreateTexture(nil, "BACKGROUND")
titleBg:SetAllPoints(titleBar)
titleBg:SetTexture(0.12, 0.10, 0.05, 1)

local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleText:SetPoint("LEFT", titleBar, "LEFT", 8, 0)
titleText:SetText("RaidMark -- Mesa de Tacticas")
titleText:SetTextColor(0.4, 0.8, 1, 1)

-- Boton cerrar
local closeBtn = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -2, -2)
closeBtn:SetScript("OnClick", function() MF.Hide() end)

-- Boton "?" de ayuda
local helpBtn = CreateFrame("Button", nil, mainFrame)
helpBtn:SetWidth(18); helpBtn:SetHeight(18)
helpBtn:SetPoint("RIGHT", closeBtn, "LEFT", -2, 0)
helpBtn:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 6, insets={left=1,right=1,top=1,bottom=1}
})
helpBtn:SetBackdropColor(0.1, 0.1, 0.15, 0.95)
helpBtn:SetBackdropBorderColor(0.5, 0.75, 1, 0.9)
local helpFs = helpBtn:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
helpFs:SetPoint("CENTER",helpBtn,"CENTER",0,0)
helpFs:SetText("?")
helpFs:SetTextColor(0.5, 0.85, 1, 1)
helpBtn:EnableMouse(true)

-- Panel de ayuda
local helpFrame = CreateFrame("Frame", "RaidMarkHelp", mainFrame)
helpFrame:SetWidth(420); helpFrame:SetHeight(460)
helpFrame:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -24, -28)
helpFrame:SetFrameStrata("FULLSCREEN_DIALOG")
helpFrame:SetFrameLevel(200)
helpFrame:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 10, insets={left=4,right=4,top=4,bottom=4}
})
helpFrame:SetBackdropColor(0.04, 0.04, 0.06, 0.97)
helpFrame:SetBackdropBorderColor(0.5, 0.75, 1, 1)
helpFrame:EnableMouse(true)
helpFrame:Hide()

-- Titulo del panel
local helpTitle = helpFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
helpTitle:SetPoint("TOP", helpFrame, "TOP", 0, -10)
helpTitle:SetText("RaidMark — Guia Rapida")
helpTitle:SetTextColor(0.5, 0.9, 1, 1)

-- Boton cerrar ayuda
local helpClose = CreateFrame("Button", nil, helpFrame, "UIPanelCloseButton")
helpClose:SetPoint("TOPRIGHT", helpFrame, "TOPRIGHT", 2, 2)
helpClose:SetScript("OnClick", function() helpFrame:Hide() end)

-- ScrollFrame para el contenido
local helpScroll = CreateFrame("ScrollFrame", "RaidMarkHelpScroll", helpFrame, "UIPanelScrollFrameTemplate")
helpScroll:SetPoint("TOPLEFT",  helpFrame, "TOPLEFT",  8, -28)
helpScroll:SetPoint("BOTTOMRIGHT", helpFrame, "BOTTOMRIGHT", -26, 8)
helpScroll:EnableMouseWheel(true)
helpScroll:SetScript("OnMouseWheel", function()
    local cur = helpScroll:GetVerticalScroll()
    local max = helpScroll:GetVerticalScrollRange()
    local n   = cur - arg1 * 20
    if n < 0 then n = 0 end
    if n > max then n = max end
    helpScroll:SetVerticalScroll(n)
end)

local helpContent = CreateFrame("Frame", nil, helpScroll)
helpContent:SetWidth(380)
helpContent:SetHeight(1)
helpScroll:SetScrollChild(helpContent)

local HELP_TEXT = [[|cff88ddff[ICONOS]|r
Selecciona un icono del panel derecho y haz click en el mapa para colocarlo.
Drag = mover  |  Click derecho = eliminar

|cff88ddff[FLECHAS]|r
Click en el boton de flecha → elige direccion y color (rojo/blanco/amarillo).
Cuadrado verde = hitbox: drag=mover, rueda=estirar, click derecho=eliminar.
Solo RL y Assists pueden estirar.

|cff88ddff[ESCENAS - 40 SLOTS]|r
[S] = guardar  |  1 click en slot = seleccionar  |  2 clicks = cargar
Gris=vacio · Rojo=seleccionado · Amarillo=con contenido · Verde=posicionamiento
Lienzo vacio + [S] = borra el slot.
GS1▼ cambia entre 10 grupos de 4 slots.

|cff88ddff[POSICIONAMIENTO OFFLINE]|r
1. M Offline (confirmar 2 veces) → coloca cuadritos de rol en el mapa (max 40).
2. Guarda en un slot → queda verde.
3. En raid: selecciona slot verde (rojo) → Sync P → raiders van a sus posiciones.
Sync P respeta posiciones manuales. Se puede repetir al conectarse mas raiders.
Reset P devuelve todos los raiders del lienzo al panel.

|cff88ddff[ROLES DE RAIDER]|r
Puntitos H·D·D·T en cada raider = asignar rol manual (click activa/desactiva).
Boton [v] + [Filtrar] = ordena raiders por rol en el panel.

|cff88ddff[AUTO-ASIGNAR]|r
Botones Healer/DD M/DD R/Tank → spamea /rw, lee /raid 10 seg.
Raiders responden 1=H 2=DDM 3=DDR 4=T.
Auto-Total = pide todos a la vez en 20 seg, reporta cuantos respondieron.
Solo un autoasignador activo a la vez. Roles persisten entre sesiones.

|cff88ddff[SYNC]|r
Sync = sincroniza el estado completo del lienzo con todo el raid.
Sync P = posiciona raiders segun slot verde seleccionado (ver Posicionamiento).

|cff88ddff[MODO OFFLINE]|r
M Offline = modo diseno sin red. Assist se desactiva automaticamente.
Sync/Auto-assign bloqueados. Sistema de escenas disponible.
Salir limpia el lienzo y restaura Assist.

|cff88ddff[PERMISOS]|r
RL = todo  |  Assist = colocar y mover  |  Raider = solo ver
Assist ON/OFF en la toolbar. Se desactiva al entrar a Offline.

|cff88ddff[GRID]|r
Boton Grid → panel flotante con sliders de opacidad y densidad.

|cff88ddff[COMANDOS]|r
/rm          abrir/cerrar
/rm clear    limpiar lienzo
/rm map <k>  cambiar mapa
/rm assist on/off]]

-- Crear el texto en el scroll
local helpText = helpContent:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
helpText:SetPoint("TOPLEFT", helpContent, "TOPLEFT", 4, -4)
helpText:SetWidth(370)
helpText:SetText(HELP_TEXT)
helpText:SetTextColor(0.88, 0.88, 0.88, 1)
helpText:SetJustifyH("LEFT")
helpText:SetSpacing(2)

-- Ajustar altura del contenido al texto
local textH = helpText:GetHeight() + 16
helpContent:SetHeight(math.max(1, textH))

helpBtn:SetScript("OnClick", function()
    if helpFrame:IsVisible() then
        helpFrame:Hide()
    else
        helpFrame:Show()
    end
end)
helpBtn:SetScript("OnEnter", function()
    GameTooltip:SetOwner(helpBtn,"ANCHOR_BOTTOM")
    GameTooltip:SetText("Ayuda / Guia Rapida")
    GameTooltip:Show()
end)
helpBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- -- Toolbar -----------------------------------------------------
local toolbar = CreateFrame("Frame", nil, mainFrame)
toolbar:SetWidth(MAP_W)
toolbar:SetHeight(TOOLBAR_H)
toolbar:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, -30)

local toolbarBg = toolbar:CreateTexture(nil, "BACKGROUND")
toolbarBg:SetAllPoints(toolbar)
toolbarBg:SetTexture(0.08, 0.07, 0.04, 1)

-- -- Area de mapa (content) ---------------------------------------
local contentFrame = CreateFrame("Frame", "RaidMarkContent", mainFrame)
contentFrame:SetWidth(MAP_W)
contentFrame:SetHeight(MAP_H)
contentFrame:SetPoint("TOPLEFT", toolbar, "BOTTOMLEFT", 0, 0)
contentFrame:EnableMouse(true)

local mapTexture = contentFrame:CreateTexture(nil, "BACKGROUND")
mapTexture:SetAllPoints(contentFrame)
mapTexture:SetTexture(0.1, 0.1, 0.1, 1)   -- fondo gris hasta cargar mapa

MF.contentFrame = contentFrame

-- Click en el mapa para colocar el icono seleccionado
contentFrame:SetScript("OnMouseDown", function()
    -- SEGURO: Prioridad absoluta al puntero. Si ALT está pulsado, no colocar icono.
    if IsAltKeyDown() then return end
    
    if arg1 ~= "LeftButton" then return end
    if not RM.Permissions.CanPlace() then return end
    if not MF.selectedIconType then return end

    local mLeft = contentFrame:GetLeft()
    local mTop  = contentFrame:GetTop()
    local mW    = contentFrame:GetWidth()
local mH    = contentFrame:GetHeight()
    local cx, cy = GetCursorPosition()
    
    -- NUEVO: Lee la escala real y efectiva del mapa, no solo la de la interfaz global
    local scale = contentFrame:GetEffectiveScale() 
    
    cx = cx / scale
    cy = cy / scale
    local nx = (cx - mLeft) / mW
    local ny = (mTop - cy)  / mH

    nx = math.max(0.01, math.min(0.99, nx))
    ny = math.max(0.01, math.min(0.99, ny))

    -- Para iconos de miembro, el label es el nombre
    local label = ""
    if MF.selectedMemberName then
        label = MF.selectedMemberName
        MF.selectedMemberName = nil
    end

    RM.Icons.PlaceNew(MF.selectedIconType, nx, ny, label)
end)

-- Pausar puntero cuando se presiona cualquier boton del mouse sobre el mapa
contentFrame:SetScript("OnMouseDown", function()

if IsAltKeyDown() then return end

    RM.state.pointerMouseBtn = true
    -- logica original de colocar iconos
    if arg1 ~= "LeftButton" then return end
    if not RM.Permissions.CanPlace() then return end
    if not MF.selectedIconType then return end

    local mLeft = contentFrame:GetLeft()
    local mTop  = contentFrame:GetTop()
    local mW    = contentFrame:GetWidth()
local mH    = contentFrame:GetHeight()
    local cx, cy = GetCursorPosition()
    
    -- NUEVO: Lee la escala real y efectiva del mapa, no solo la de la interfaz global
    local scale = contentFrame:GetEffectiveScale() 
    
    cx = cx / scale
    cy = cy / scale
    local nx = (cx - mLeft) / mW
    local ny = (mTop - cy)  / mH
    nx = math.max(0.01, math.min(0.99, nx))
    ny = math.max(0.01, math.min(0.99, ny))
    local label = ""
    if MF.selectedMemberName then
        label = MF.selectedMemberName
        MF.selectedMemberName = nil
    end

    -- Bloquear colocacion de fakes fuera del modo offline
    if RM.IsOfflineRoleIcon and RM.IsOfflineRoleIcon(MF.selectedIconType) and not RM.state.offlineMode then
        if MF.ConsoleMsg then MF.ConsoleMsg("Los iconos de posicion solo se colocan en Modo Offline.", 1, 0.4, 0.1) end
        return
    end

    -- Limite de 40 fakes en modo offline
    if RM.state.offlineMode and RM.IsOfflineRoleIcon and RM.IsOfflineRoleIcon(MF.selectedIconType) then
        local fakeCount = 0
        for _, ic in pairs(RM.state.placedIcons) do
            if RM.IsOfflineRoleIcon(ic.iconType) then fakeCount = fakeCount + 1 end
        end
        if fakeCount >= 40 then
            if MF.ConsoleMsg then MF.ConsoleMsg("40/40 - Limite de posiciones alcanzado.", 1, 0.4, 0.1) end
            return
        end
    end

    RM.Icons.PlaceNew(MF.selectedIconType, nx, ny, label,
        MF.selectedIconColorR, MF.selectedIconColorG, MF.selectedIconColorB)
end)

contentFrame:SetScript("OnMouseUp", function()
    RM.state.pointerMouseBtn = false
end)


-- -- Panel lateral -----------------------------------------------
local sidePanel = CreateFrame("Frame", nil, mainFrame)
sidePanel:SetWidth(PANEL_W)
sidePanel:SetHeight(TOTAL_H - 30)
sidePanel:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", MAP_W, -30)

local sideBg = sidePanel:CreateTexture(nil, "BACKGROUND")
sideBg:SetAllPoints(sidePanel)
sideBg:SetTexture(0.07, 0.06, 0.03, 1)

-- Separador vertical
local sep = sidePanel:CreateTexture(nil, "ARTWORK")
sep:SetWidth(1)
sep:SetHeight(TOTAL_H - 30)
sep:SetPoint("TOPLEFT", sidePanel, "TOPLEFT", 0, 0)
sep:SetTexture(0.4, 0.35, 0.2, 0.8)

-- -- Helper: boton de icono en el panel --------------------------
local function makeIconButton(parent, iconType, texPath, size, xPos, yPos, tooltip)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetWidth(size)
    btn:SetHeight(size)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", xPos, yPos)

    local tex = btn:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(btn)
    tex:SetTexture(texPath)
    -- Aplicar coordenadas de atlas si es necesario
    local tc = RM.ICON_TEXCOORD and RM.ICON_TEXCOORD[iconType]
    if tc then
        tex:SetTexCoord(tc[1], tc[2], tc[3], tc[4])
    end

    -- Highlight de seleccion
    local hl = btn:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints(btn)
    hl:SetTexture(1, 1, 1, 0.2)

    btn:SetScript("OnClick", function()
        MF.selectedIconType   = iconType
        MF.selectedMemberName = nil
        MF.HighlightSelected(btn)
    end)

    btn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(btn, "ANCHOR_LEFT")
        GameTooltip:SetText(tooltip or iconType)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    btn:EnableMouse(true)
    return btn
end





-- -- Botones de iconos de rol ------------------------------------
local ICON_BTN = 46  -- tamanio del boton de icono en el panel
local ICON_GAP = 4

local ROLE_BUTTONS = {
    { type="TANK",      label="Tank",   x=8,                        y=-20 },
    { type="HEALER",    label="Healer", x=8+ICON_BTN+ICON_GAP,      y=-20 },
    { type="DPS",       label="DPS",    x=8+(ICON_BTN+ICON_GAP)*2,  y=-20 },
    { type="DPS_MELEE", label="Melee",  x=8+(ICON_BTN+ICON_GAP)*3,  y=-20 },
    { type="CASTER",    label="Caster", x=8,                        y=-20-(ICON_BTN+ICON_GAP) },
    { type="ARROW",     label="Flecha", x=8+ICON_BTN+ICON_GAP,      y=-20-(ICON_BTN+ICON_GAP), isArrowDropdown=true },
}

local AREAS_Y_START = -20 - (ICON_BTN+ICON_GAP)*2 - 20  -- offset para seccion Circulos

local CIRCLE_BUTTONS = {
    { type="CIRCLE_S",  label="S",  x=8,                        y=AREAS_Y_START },
    { type="CIRCLE_M",  label="M",  x=8+ICON_BTN+ICON_GAP,      y=AREAS_Y_START },
    { type="CIRCLE_L",  label="L",  x=8+(ICON_BTN+ICON_GAP)*2,  y=AREAS_Y_START },
    { type="CIRCLE_XL", label="XL", x=8+(ICON_BTN+ICON_GAP)*3,  y=AREAS_Y_START },
}

local SKULLS_Y_START = AREAS_Y_START - (ICON_BTN+ICON_GAP)*2 + 10

local SKULL_BUTTONS = {
    { type="SKULL1",       label="Ambush",   x=8,                        y=SKULLS_Y_START },
    { type="SKULL2",       label="DCoil",    x=8+ICON_BTN+ICON_GAP,      y=SKULLS_Y_START },
    { type="SKULL3",       label="Undead",   x=8+(ICON_BTN+ICON_GAP)*2,  y=SKULLS_Y_START },
    { type="MARK_STAR",    label="Estrella", x=8,                        y=SKULLS_Y_START-(ICON_BTN+ICON_GAP) },
    { type="MARK_CIRCLE",  label="Circulo",  x=8+ICON_BTN+ICON_GAP,      y=SKULLS_Y_START-(ICON_BTN+ICON_GAP) },
    { type="MARK_DIAMOND", label="Diamante", x=8+(ICON_BTN+ICON_GAP)*2,  y=SKULLS_Y_START-(ICON_BTN+ICON_GAP) },
    { type="MARK_TRIANGLE",label="Triangulo",x=8+(ICON_BTN+ICON_GAP)*3,  y=SKULLS_Y_START-(ICON_BTN+ICON_GAP) },
    { type="MARK_MOON",    label="Luna",     x=8,                        y=SKULLS_Y_START-(ICON_BTN+ICON_GAP)*2 },
    { type="MARK_SQUARE",  label="Cuadrado", x=8+ICON_BTN+ICON_GAP,      y=SKULLS_Y_START-(ICON_BTN+ICON_GAP)*2 },
    { type="MARK_CROSS",   label="Cruz",     x=8+(ICON_BTN+ICON_GAP)*2,  y=SKULLS_Y_START-(ICON_BTN+ICON_GAP)*2 },
    { type="MARK_SKULL",   label="Calavera", x=8+(ICON_BTN+ICON_GAP)*3,  y=SKULLS_Y_START-(ICON_BTN+ICON_GAP)*2 },
}

local MEMBER_PANEL_Y_OFFSET = SKULLS_Y_START - (ICON_BTN+ICON_GAP)*3 - 8

MF.selectedIconType   = nil
MF.selectedIconColorR = nil
MF.selectedIconColorG = nil
MF.selectedIconColorB = nil
MF.selectedMemberName = nil
MF.allButtons         = {}

-- Puntero local y remoto
local localPointerFrame      = nil
local localPointerX          = 0
local localPointerY          = 0
local remotePointerPaths     = {}
local lastPointerReceived    = {}   -- [colorName] = GetTime() del ultimo PTR recibido
local POINTER_SIZE           = 24
local POINTER_PATH_MAX       = 100
local POINTER_PATH_TTL       = 2.0
local POINTER_INACTIVITY_TTL = 10   -- segundos sin PTR para auto-liberar slot



-- -- Frame de actualizacion del puntero local -------------------
local pointerUpdateFrame = CreateFrame("Frame", "RaidMarkPointerUpdate")
pointerUpdateFrame:SetScript("OnUpdate", function()
    if not RM.state.pointerActive then return end
    if not localPointerFrame then return end
    if RM.state.pointerMouseBtn or not IsAltKeyDown() then
        localPointerFrame:Hide()
        return
    end

    -- Verificar que el cursor este sobre el contentFrame
    local mLeft = contentFrame:GetLeft()
    local mTop  = contentFrame:GetTop()
    local mW    = contentFrame:GetWidth()
    local mH    = contentFrame:GetHeight()
    if not mLeft then return end

local cx, cy = GetCursorPosition()
    
    -- NUEVO: Aplica la misma corrección al puntero visual
    local scale  = contentFrame:GetEffectiveScale() 
    
    cx = cx / scale
    cy = cy / scale

    -- Solo mostrar si el cursor esta dentro del mapa

    -- Solo mostrar si el cursor esta dentro del mapa
    if cx < mLeft or cx > mLeft + mW or cy < mTop - mH or cy > mTop then
        localPointerFrame:Hide()
        return
    end

    -- Posicion normalizada
    localPointerX = (cx - mLeft) / mW
    localPointerY = (mTop - cy)  / mH
    localPointerX = math.max(0.01, math.min(0.99, localPointerX))
    localPointerY = math.max(0.01, math.min(0.99, localPointerY))

    localPointerFrame:ClearAllPoints()
    localPointerFrame:SetPoint("CENTER", contentFrame, "TOPLEFT",
                               localPointerX * mW, -localPointerY * mH)
    localPointerFrame:Show()
end)

-- Devuelve la ultima posicion normalizada del puntero local (para network.lua)
function MF.GetPointerPos()
    if localPointerFrame and localPointerFrame:IsVisible() then
        return localPointerX, localPointerY
    end
    return nil, nil
end

-- Función auxiliar para crear físicamente el punto del rastro
function MF.CreateShadowFrame(path, px, py, sr, sg, sb)
    local dot = CreateFrame("Frame", nil, MF.contentFrame)
    dot:SetWidth(POINTER_SIZE)
    dot:SetHeight(POINTER_SIZE)
    dot:SetFrameLevel(MF.contentFrame:GetFrameLevel() + 3)
    local mW = MF.contentFrame:GetWidth()
    local mH = MF.contentFrame:GetHeight()
    dot:SetPoint("CENTER", MF.contentFrame, "TOPLEFT", px * mW, -py * mH)

    local tex = dot:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(dot)
    tex:SetTexture(RM.ICON_PATH .. "icon_circle_S")
    tex:SetVertexColor(sr, sg, sb, 1.0)

    dot.ttl, dot.elapsed = POINTER_PATH_TTL, 0
    dot:SetScript("OnUpdate", function()
        dot.elapsed = dot.elapsed + arg1
        if dot.elapsed >= dot.ttl then
            dot:Hide()
            dot:SetScript("OnUpdate", nil)
        else
            local fade = dot.elapsed / dot.ttl
            if fade > 0.7 then
                tex:SetVertexColor(sr, sg, sb, (1 - fade) / 0.3)
            end
        end
    end)
    table.insert(path, dot)
    if table.getn(path) > POINTER_PATH_MAX then
        local oldest = table.remove(path, 1)
        oldest:Hide()
        oldest:SetScript("OnUpdate", nil)
    end
end

-- Nueva versión con interpolación para rastro unido
function MF.AddRemotePointerDot(sender, colorName, px, py)
    lastPointerReceived[colorName] = GetTime()
    
    local slot = nil
    for _, s in ipairs(RM.state.pointerSlots) do
        if s.color == colorName then slot = s; break end
    end
    if not slot then return end

    if not remotePointerPaths[sender] then remotePointerPaths[sender] = {} end
    local path = remotePointerPaths[sender]

    -- Lógica de Interpolación:
    local stepSize = 0.012  -- Densidad del rastro (menor = más sólido)
    local lastX = slot.lastX or px
    local lastY = slot.lastY or py
    
    local dx = px - lastX
    local dy = py - lastY
    local dist = math.sqrt(dx*dx + dy*dy)

    -- Si el movimiento es normal (menor al 25% del mapa), rellenamos el hueco
    if dist > 0 and dist < 0.25 then
        local steps = math.floor(dist / stepSize)
        if steps > 0 then
            for i = 1, steps do
                local t = i / steps
                MF.CreateShadowFrame(path, lastX + dx*t, lastY + dy*t, slot.r, slot.g, slot.b)
            end
        else
            MF.CreateShadowFrame(path, px, py, slot.r, slot.g, slot.b)
        end
    else
        MF.CreateShadowFrame(path, px, py, slot.r, slot.g, slot.b)
    end

    -- Guardamos la posición actual para el próximo cálculo
    slot.lastX, slot.lastY = px, py
end

-- Mini consola dinamica con fade in/out entre mensajes idle
local consolePriorityTimer = 0
local assignCooldown       = 0   -- cooldown post auto-assign
local ASSIGN_COOLDOWN_TIME = 10
local consoleIdleIndex     = 1
local CONSOLE_PRIORITY_TTL = 5
local CONSOLE_SHOW_TIME    = 3.5   -- segundos visible cada mensaje
local CONSOLE_FADE_SPEED   = 2.0   -- alpha por segundo

local consoleFadeDir    = 0    -- 0=visible, 1=fade out, -1=fade in
local consoleFadeAlpha  = 1.0
local consoleShowTimer  = CONSOLE_SHOW_TIME
local consoleCurrentMsg = nil  -- { text, r, g, b }

local consoleIdleMessages = {
    { text = "RaidMark v" .. RM.VERSION,              r = 0.4, g = 0.7, b = 1.0 },
    { text = "By Holle - South Seas Server",           r = 0.5, g = 0.5, b = 0.5 },
    { text = "Puntero: activa check, mueve sin click", r = 0.8, g = 0.8, b = 0.3 },
    { text = "Sync (RL): limpia slots de puntero",     r = 0.3, g = 1.0, b = 0.4 },
}

local function consoleApplyAlpha()
    if not MF.consoleText or not consoleCurrentMsg then return end
    MF.consoleText:SetTextColor(
        consoleCurrentMsg.r, consoleCurrentMsg.g, consoleCurrentMsg.b, consoleFadeAlpha)
end

local function consoleNextIdle()
    consoleCurrentMsg = consoleIdleMessages[consoleIdleIndex]
    consoleIdleIndex = math.mod(consoleIdleIndex, table.getn(consoleIdleMessages)) + 1
    if MF.consoleText then
        MF.consoleText:SetText(consoleCurrentMsg.text)
    end
    consoleApplyAlpha()
end

function MF.ConsoleMsg(text, r, g, b)
    r = r or 0.7
    g = g or 0.9
    b = b or 1
    consolePriorityTimer = CONSOLE_PRIORITY_TTL
    consoleFadeDir   = 0
    consoleFadeAlpha = 1.0
    consoleCurrentMsg = { text = text, r = r, g = g, b = b }
    if MF.consoleText then
        MF.consoleText:SetText(text)
        MF.consoleText:SetTextColor(r, g, b, 1)
    end
end

-- Detector de inactividad de punteros + fade de consola
local INACTIVITY_CHECK = 0
local consoleUpdateFrame = CreateFrame("Frame", "RaidMarkConsoleUpdate")
consoleUpdateFrame:SetScript("OnUpdate", function()
    local dt = arg1

    -- Detector de inactividad de slots de puntero
    INACTIVITY_CHECK = INACTIVITY_CHECK + dt
    if INACTIVITY_CHECK >= 2 then
        INACTIVITY_CHECK = 0
        local now = GetTime()
        local changed = false
        for i, slot in ipairs(RM.state.pointerSlots) do
            if slot.owner and slot.owner ~= UnitName("player") then
                local lastTime = lastPointerReceived[slot.color] or 0
if lastTime > 0 and (now - lastTime) > POINTER_INACTIVITY_TTL then
                    slot.owner = nil
                    slot.lastX = nil -- Limpiar memoria de posición
                    slot.lastY = nil -- Limpiar memoria de posición
                    lastPointerReceived[slot.color] = nil
                    changed = true
                    if RM.state.myPointerSlot == i then
                        if MF.SetPointerActive then MF.SetPointerActive(false) end
                    end
                end
            end
        end
        if changed then MF.UpdatePointerSlotUI() end
    end

    -- Decrementar cooldown de auto-assign
    if assignCooldown > 0 then
        assignCooldown = assignCooldown - dt
        if assignCooldown < 0 then assignCooldown = 0 end
    end

    -- Fade de consola
    if consolePriorityTimer > 0 then
        consolePriorityTimer = consolePriorityTimer - dt
        if consolePriorityTimer <= 0 then
            consolePriorityTimer = 0
            consoleFadeDir   = -1
            consoleFadeAlpha = 0
            consoleNextIdle()
            consoleShowTimer = CONSOLE_SHOW_TIME
        end
        return
    end

    if not MF.consoleText then return end

    if consoleFadeDir == 0 then
        consoleShowTimer = consoleShowTimer - dt
        if consoleShowTimer <= 0 then
            consoleFadeDir = 1  -- empieza fade out
        end

    elseif consoleFadeDir == 1 then
        consoleFadeAlpha = consoleFadeAlpha - CONSOLE_FADE_SPEED * dt
        if consoleFadeAlpha <= 0 then
            consoleFadeAlpha = 0
            consoleFadeDir   = -1  -- empieza fade in del siguiente
            consoleNextIdle()
        end
        consoleApplyAlpha()

    elseif consoleFadeDir == -1 then
        consoleFadeAlpha = consoleFadeAlpha + CONSOLE_FADE_SPEED * dt
        if consoleFadeAlpha >= 1 then
            consoleFadeAlpha = 1
            consoleFadeDir   = 0
            consoleShowTimer = CONSOLE_SHOW_TIME
        end
        consoleApplyAlpha()
    end
end)

-- ── Sistema de aviso de memoria ──────────────────────────────────
local MEM_WARN_THRESHOLD  = 700    -- aviso amigable
local MEM_CRIT_THRESHOLD  = 1100   -- aviso critico con parpadeo
local memWarnTimer        = 0
local memWarnInterval     = 20     -- segundos entre avisos normales
local memBlinkTimer       = 0
local memBlinkState       = false
local memCritActive       = false
local memWarnDisabled     = false  -- usuario deshabilitó alarma amigable
local memCritDisabled     = false  -- usuario deshabilitó alarma critica

-- Boton de alarma encima del box (se crea lazy la primera vez)
local memAlarmBtn         = nil
local memAlarmBtnCreated  = false

local function createMemAlarmBtn()
    if memAlarmBtnCreated then return end
    if not MF.consoleFrame then return end
    memAlarmBtnCreated = true

    memAlarmBtn = CreateFrame("Button", "RaidMarkMemAlarmBtn", MF.consoleFrame)
    memAlarmBtn:SetWidth(12); memAlarmBtn:SetHeight(12)
    memAlarmBtn:SetPoint("BOTTOM", MF.consoleFrame, "TOP", 0, 2)
    memAlarmBtn:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 5, insets={left=1,right=1,top=1,bottom=1}
    })
    memAlarmBtn:SetBackdropColor(0.1, 0.3, 0.9, 1)
    memAlarmBtn:SetBackdropBorderColor(0.3, 0.6, 1, 1)
    memAlarmBtn:EnableMouse(true)
    local alarmLbl = memAlarmBtn:CreateFontString(nil,"OVERLAY")
    alarmLbl:SetFont("Fonts\\FRIZQT__.TTF", 6, "OUTLINE")
    alarmLbl:SetPoint("RIGHT", memAlarmBtn, "LEFT", -4, 0)
    alarmLbl:SetText("deshabilitar alarma")
    alarmLbl:SetTextColor(1,1,1,1)
    memAlarmBtn.lbl = alarmLbl
    memAlarmBtn:SetScript("OnClick", function()
        if memCritActive then
            memCritDisabled = true
            memCritActive   = false
            consolePriorityTimer = 0
            if MF.consoleText then BigFont(MF.consoleText, 9) end
        else
            memWarnDisabled = true
        end
        memAlarmBtn:Hide()
    end)
    memAlarmBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(memAlarmBtn,"ANCHOR_TOP")
        GameTooltip:SetText("Deshabilitar alarma de memoria")
        GameTooltip:AddLine("El riesgo persiste — usa /reload cuando puedas", 0.8,0.6,0.3,true)
        GameTooltip:Show()
    end)
    memAlarmBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    memAlarmBtn:Hide()
end

local function showMemAlarmBtn(isCrit)
    createMemAlarmBtn()
    if not memAlarmBtn then return end
    if isCrit then
        memAlarmBtn:SetBackdropColor(0.7, 0.05, 0.05, 1)
        memAlarmBtn:SetBackdropBorderColor(1, 0.2, 0.2, 1)
        memAlarmBtn.lbl:SetText("DESHABILITAR ALARMA")
        memAlarmBtn.lbl:SetTextColor(1, 0.9, 0.1, 1)
    else
        memAlarmBtn:SetBackdropColor(0.1, 0.3, 0.9, 1)
        memAlarmBtn:SetBackdropBorderColor(0.3, 0.6, 1, 1)
        memAlarmBtn.lbl:SetText("deshabilitar alarma")
        memAlarmBtn.lbl:SetTextColor(1, 1, 1, 1)
    end
    memAlarmBtn:Show()
end

local memWarnFrame = CreateFrame("Frame", "RaidMarkMemWarn")
memWarnFrame:SetScript("OnUpdate", function()
    local dt = arg1
    local count = RM.Icons and RM.Icons.frameCount or 0

    -- Modo critico
    if count >= MEM_CRIT_THRESHOLD and not memCritDisabled then
        if not memCritActive then
            memCritActive = true
            memBlinkTimer = 0
            memBlinkState = true
            showMemAlarmBtn(true)
        end
        memBlinkTimer = memBlinkTimer + dt
        if memBlinkTimer >= 1.0 then
            memBlinkTimer = 0
            memBlinkState = not memBlinkState
            if MF.consoleText then
                MF.consoleText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
                MF.consoleText:SetText('MEMORIA COMPROMETIDA USA "/reload" !!!')
                MF.consoleText:SetTextColor(memBlinkState and 1 or 1,
                                             memBlinkState and 0.1 or 0.85,
                                             memBlinkState and 0.1 or 0.0, 1)
            end
        end
        consolePriorityTimer = 99
        return
    end

    -- Salir modo critico (por reload o deshabilitado)
    if memCritActive and (count < MEM_CRIT_THRESHOLD or memCritDisabled) then
        memCritActive = false
        consolePriorityTimer = 0
        if MF.consoleText then BigFont(MF.consoleText, 9) end
        if memAlarmBtn then memAlarmBtn:Hide() end
    end

    -- Modo advertencia
    if count >= MEM_WARN_THRESHOLD and not memWarnDisabled and not memCritDisabled then
        memWarnTimer = memWarnTimer + dt
        if memWarnTimer >= memWarnInterval then
            memWarnTimer = 0
            showMemAlarmBtn(false)
            if MF.ConsoleMsg then
                MF.ConsoleMsg("Memoria del addon casi llena. Recomendamos /reload", 1, 0.7, 0.1)
            end
        end
    else
        if count < MEM_WARN_THRESHOLD then
            memWarnTimer = 0
            -- Si baja del umbral (no ocurre en sesion normal), ocultar boton
            if memAlarmBtn and memAlarmBtn:IsVisible() and not memCritActive then
                memAlarmBtn:Hide()
            end
        end
    end
end)

-- Actualizar indicadores visuales de slots en la toolbar
function MF.UpdatePointerSlotUI()
    if not MF.slotIndicators then return end
    for i, ind in ipairs(MF.slotIndicators) do
        local slot = RM.state.pointerSlots[i]
        if slot.owner or (i == 1 and RM.Permissions.IsRL()) then
            ind:SetAlpha(1.0)
        else
            ind:SetAlpha(0.25)
        end
    end
end

local function buildPointerLocalFrame()
    localPointerFrame = CreateFrame("Frame", nil, contentFrame)
    localPointerFrame:SetWidth(POINTER_SIZE)
    localPointerFrame:SetHeight(POINTER_SIZE)
    localPointerFrame:SetFrameLevel(contentFrame:GetFrameLevel() + 5)
    local tex = localPointerFrame:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(localPointerFrame)
    tex:SetTexture(RM.ICON_PATH .. "icon_circle_S")
    tex:SetVertexColor(1, 0.1, 0.1, 0.9)  -- rojo por defecto, cambia con el slot
    localPointerFrame.tex = tex
    localPointerFrame:Hide()
end

local function buildRoleButtons()
    -- Label "Iconos de Rol" con fondo para que sea legible
    local lbl = sidePanel:CreateFontString(nil,"OVERLAY","GameFontNormal")
    lbl:SetPoint("TOPLEFT", sidePanel, "TOPLEFT", 8, -6)
    lbl:SetText("Iconos de Rol")
    BigFont(lbl, 12)
    lbl:SetTextColor(1, 0.9, 0.4, 1)

    for _, def in ipairs(ROLE_BUTTONS) do
        if def.isArrowDropdown then
            -- Boton especial: abre/cierra el dropdown de flechas direccionales
            local btn = CreateFrame("Button", "RaidMarkArrowDropBtn", sidePanel)
            btn:SetWidth(ICON_BTN)
            btn:SetHeight(ICON_BTN)
            btn:SetPoint("TOPLEFT", sidePanel, "TOPLEFT", def.x, def.y)
            local tex = btn:CreateTexture(nil, "ARTWORK")
            tex:SetAllPoints(btn)
            tex:SetTexture(RM.ICON_TEXTURE["ARROW"])
            local hl = btn:CreateTexture(nil, "HIGHLIGHT")
            hl:SetAllPoints(btn)
            hl:SetTexture(1, 1, 1, 0.25)
            btn:SetScript("OnClick", function()
                MF.ToggleArrowDropdown(btn)
            end)
            btn:SetScript("OnEnter", function()
                GameTooltip:SetOwner(btn, "ANCHOR_LEFT")
                GameTooltip:SetText("Flechas Direccionales")
                GameTooltip:AddLine("Click para desplegar", 0.7, 0.7, 0.7, true)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            btn:EnableMouse(true)
            MF.arrowDropBtn = btn
        else
            local btn = makeIconButton(
                sidePanel, def.type,
                RM.ICON_TEXTURE[def.type],
                ICON_BTN, def.x, def.y, def.label
            )
            table.insert(MF.allButtons, btn)
        end
    end

    -- -- Dropdown de flechas direccionales -------------------------
    -- ── Dropdown de flechas direccionales ─────────────────────────
    local DD_BTN  = ICON_BTN
    local ROW_H   = DD_BTN + 14       -- boton + label
    local DD_COLS = 4
    local DD_ROWS = 6                  -- 3 colores x (cardinales + diagonales)
    local DD_SEP  = 8                  -- separador entre grupos
    local DD_W    = DD_COLS * (DD_BTN + ICON_GAP) - ICON_GAP + 16
    local DD_H    = DD_ROWS * ROW_H + DD_SEP + 24

    local arrowDD = CreateFrame("Frame", "RaidMarkArrowDD", sidePanel)
    arrowDD:SetWidth(DD_W)
    arrowDD:SetHeight(DD_H)
    arrowDD:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets   = { left=3, right=3, top=3, bottom=3 },
    })
    arrowDD:SetBackdropColor(0.04, 0.04, 0.05, 1.0)
    arrowDD:SetBackdropBorderColor(1, 0.82, 0.0, 1)
    arrowDD:EnableMouse(true)
    arrowDD:Hide()

    -- Overlay: bloquea clics debajo cuando el DD esta abierto
    local arrowDDOverlay = CreateFrame("Frame", "RaidMarkArrowDDOverlay", UIParent)
    arrowDDOverlay:SetAllPoints(UIParent)
    arrowDDOverlay:SetFrameStrata("FULLSCREEN")
    arrowDDOverlay:SetFrameLevel(150)
    arrowDDOverlay:EnableMouse(true)
    arrowDDOverlay:Hide()
    arrowDDOverlay:SetScript("OnMouseDown", function()
        arrowDD:Hide()
        arrowDDOverlay:Hide()
    end)
    arrowDD:SetFrameStrata("FULLSCREEN_DIALOG")
    arrowDD:SetFrameLevel(160)

    -- Colores: rojo (fila 1), blanco (fila 2), amarillo (fila 3)
    local DD_COLORS = {
        { r=1,   g=0.2,  b=0.2,  colorLabel="Rojo"    },
        { r=1,   g=1,    b=1,    colorLabel="Blanco"  },
        { r=1,   g=0.9,  b=0.1,  colorLabel="Amarillo"},
    }

    -- Flechas base (sin sufijo de color en el tipo logico)
    local DD_BASE = {
        -- cardinales
        { base="ARROW_N",  label="N",  tex="arrow_N",  isDiag=false, col=1 },
        { base="ARROW_S",  label="S",  tex="arrow_S",  isDiag=false, col=2 },
        { base="ARROW_E",  label="E",  tex="arrow_E",  isDiag=false, col=3 },
        { base="ARROW_O",  label="O",  tex="arrow_O",  isDiag=false, col=4 },
        -- diagonales
        { base="ARROW_NE", label="NE", tex="arrow_NE", isDiag=true,  col=1 },
        { base="ARROW_NO", label="NO", tex="arrow_NO", isDiag=true,  col=2 },
        { base="ARROW_SE", label="SE", tex="arrow_SE", isDiag=true,  col=3 },
        { base="ARROW_SO", label="SO", tex="arrow_SO", isDiag=true,  col=4 },
    }

    -- Construir botones: para cada flecha base x 3 colores
    -- Filas 1-3: cardinales (blanco, azul, verde)
    -- Filas 4-6: diagonales (blanco, azul, verde)
    for _, base in ipairs(DD_BASE) do
        local groupOffset = base.isDiag and 3 or 0   -- diagonales empiezan en fila 4
        for ci, clr in ipairs(DD_COLORS) do
            local row = groupOffset + ci              -- 1-3 cardinales, 4-6 diagonales
            -- yOff: separador extra entre grupo cardinal y diagonal
            local sepExtra = base.isDiag and DD_SEP or 0
            local xOff = 8 + (base.col - 1) * (DD_BTN + ICON_GAP)
            local yOff = -(8 + (row - 1) * ROW_H + sepExtra)

            local ddBtn = CreateFrame("Button", nil, arrowDD)
            ddBtn:SetWidth(DD_BTN)
            ddBtn:SetHeight(DD_BTN)
            ddBtn:SetPoint("TOPLEFT", arrowDD, "TOPLEFT", xOff, yOff)

            local t = ddBtn:CreateTexture(nil, "ARTWORK")
            t:SetAllPoints(ddBtn)
            t:SetTexture(RM.ICON_PATH .. base.tex)
            -- Tintar manteniendo canal alpha del TGA
            t:SetVertexColor(clr.r, clr.g, clr.b)

            local hl = ddBtn:CreateTexture(nil, "HIGHLIGHT")
            hl:SetAllPoints(ddBtn)
            hl:SetTexture(1, 1, 1, 0.25)

            -- Label solo en la primera columna (col=1) para no saturar
            if base.col == 1 then
                local lbl = arrowDD:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                lbl:SetPoint("LEFT", ddBtn, "LEFT", -2, -DD_BTN/2 - 6)
                lbl:SetText(clr.colorLabel)
                lbl:SetTextColor(clr.r, clr.g, clr.b, 1)
            end
            -- Label de direccion encima solo en la primera fila de color de cada grupo
            if ci == 1 then
                local dlbl = arrowDD:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                dlbl:SetPoint("BOTTOM", ddBtn, "TOP", 0, 2)
                dlbl:SetText(base.label)
                dlbl:SetTextColor(1, 0.9, 0.6, 1)
            end

            -- El tipo logico es el mismo base para todos los colores del mismo tipo
            -- El color se guarda en placedIcons para poder retintarlo al redibujar
            local capturedBase  = base.base
            local capturedTex   = base.tex
            local capturedIsDiag = base.isDiag
            local capturedR     = clr.r
            local capturedG     = clr.g
            local capturedB     = clr.b
            local capturedLabel = base.label .. " " .. clr.colorLabel

            ddBtn:SetScript("OnClick", function()
                MF.selectedIconType    = capturedBase
                MF.selectedIconTex     = capturedTex
                MF.selectedIconColorR  = capturedR
                MF.selectedIconColorG  = capturedG
                MF.selectedIconColorB  = capturedB
                MF.selectedMemberName  = nil
                if MF.arrowDropBtn then MF.HighlightSelected(MF.arrowDropBtn) end
                arrowDD:Hide()
                arrowDDOverlay:Hide()
            end)
            ddBtn:SetScript("OnEnter", function()
                GameTooltip:SetOwner(ddBtn, "ANCHOR_LEFT")
                GameTooltip:SetText(capturedLabel)
                GameTooltip:Show()
            end)
            ddBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            ddBtn:EnableMouse(true)
        end
    end

    function MF.ToggleArrowDropdown(anchorBtn)
        if arrowDD:IsVisible() then
            arrowDD:Hide()
            arrowDDOverlay:Hide()
            return
        end
        arrowDD:ClearAllPoints()
        arrowDD:SetPoint("TOPLEFT", anchorBtn, "BOTTOMLEFT", 0, -4)
        arrowDD:Show()
        arrowDDOverlay:Show()
    end

    -- Label "Areas" con fondo legible
    local lbl2 = sidePanel:CreateFontString(nil,"OVERLAY","GameFontNormal")
    lbl2:SetPoint("TOPLEFT", sidePanel, "TOPLEFT", 8, AREAS_Y_START + 14)
    lbl2:SetText("Circulos")
    BigFont(lbl2, 12)
    lbl2:SetTextColor(1, 0.9, 0.4, 1)

    for _, def in ipairs(CIRCLE_BUTTONS) do
--[[
    local tipLbl = sidePanel:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    if BigFont then BigFont(tipLbl, 10) end -- Solo si existe en ese bloque
    tipLbl:SetPoint("TOPLEFT", sidePanel, "TOPLEFT", def.x, def.y - ICON_BTN - 1)
    tipLbl:SetWidth(ICON_BTN)
    tipLbl:SetText(def.label)
    tipLbl:SetTextColor(0.8, 0.8, 0.6, 1)
    --]]
        local btn = makeIconButton(
            sidePanel, def.type,
            RM.ICON_TEXTURE[def.type],
            ICON_BTN, def.x, def.y, def.label
        )
        table.insert(MF.allButtons, btn)
    end

    -- Label seccion Calaveras y Marcas
    local lbl4 = sidePanel:CreateFontString(nil,"OVERLAY","GameFontNormal")
    lbl4:SetPoint("TOPLEFT", sidePanel, "TOPLEFT", 8, SKULLS_Y_START + 14)
    BigFont(lbl4, 12)
    lbl4:SetText("Calaveras / Marcas")
    lbl4:SetTextColor(1, 0.9, 0.4, 1)

    for _, def in ipairs(SKULL_BUTTONS) do
--[[
    local tipLbl = sidePanel:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    if BigFont then BigFont(tipLbl, 10) end -- Solo si existe en ese bloque
    tipLbl:SetPoint("TOPLEFT", sidePanel, "TOPLEFT", def.x, def.y - ICON_BTN - 1)
    tipLbl:SetWidth(ICON_BTN)
    tipLbl:SetText(def.label)
    tipLbl:SetTextColor(0.8, 0.8, 0.6, 1)
    --]]
        local btn = makeIconButton(
            sidePanel, def.type,
            RM.ICON_TEXTURE[def.type],
            ICON_BTN, def.x, def.y, def.label
        )
        table.insert(MF.allButtons, btn)
    end

    -- Label "Miembros del Raid"
    local lbl3 = sidePanel:CreateFontString(nil,"OVERLAY","GameFontNormal")
    lbl3:SetPoint("TOPLEFT", sidePanel, "TOPLEFT", 8, MEMBER_PANEL_Y_OFFSET + 14)
    lbl3:SetText("Miembros del Raid aun por ubicar")
    BigFont(lbl3, 12)
    lbl3:SetTextColor(1, 0.9, 0.4, 1)
end

-- -- Panel de miembros del raid (scrollable) ----------------------
local MEMBER_PANEL_Y    = MEMBER_PANEL_Y_OFFSET or -175
local MEMBER_BTN_H      = 22
local MEMBER_BTN_W      = PANEL_W - 100  -- espacio para 4 role dots

-- Altura disponible desde el inicio del panel hasta el fondo de la ventana
local SCROLL_H = TOTAL_H - TOOLBAR_H - 30 - math.abs(MEMBER_PANEL_Y) - 80

-- Altura minima garantizada de 80px para el panel de miembros
local SAFE_SCROLL_H = math.max(80, SCROLL_H)

local memberScrollFrame = CreateFrame("ScrollFrame", "RaidMarkMemberScroll", sidePanel, "UIPanelScrollFrameTemplate")
memberScrollFrame:SetWidth(PANEL_W - 28)        -- espacio para la scrollbar a la derecha
memberScrollFrame:SetHeight(SAFE_SCROLL_H)
memberScrollFrame:SetPoint("TOPLEFT", sidePanel, "TOPLEFT", 4, MEMBER_PANEL_Y - 52)
memberScrollFrame:EnableMouseWheel(true)
memberScrollFrame:SetScript("OnMouseWheel", function()
    local delta   = arg1
    local current = memberScrollFrame:GetVerticalScroll()
    local max     = memberScrollFrame:GetVerticalScrollRange()
    local newVal  = current - (delta * (MEMBER_BTN_H + 2) * 3)
    if newVal < 0 then newVal = 0 end
    if newVal > max then newVal = max end
    memberScrollFrame:SetVerticalScroll(newVal)
end)

local memberContent = CreateFrame("Frame", "RaidMarkMemberContent", memberScrollFrame)
memberContent:SetWidth(MEMBER_BTN_W)
memberContent:SetHeight(1)
memberScrollFrame:SetScrollChild(memberContent)

-- Divider
local divider = sidePanel:CreateTexture(nil, "ARTWORK")
divider:SetWidth(PANEL_W - 16)
divider:SetHeight(1)
divider:SetPoint("TOPLEFT", sidePanel, "TOPLEFT", 8, MEMBER_PANEL_Y - 4)
divider:SetTexture(0.4, 0.35, 0.2, 0.6)

-- Definicion de roles (usada tanto para labels como para dots)
local ROLE_DEFS = {
    { key="HEAL",  short="H", long="Healer",      r=0.2, g=1.0, b=0.3  },
    { key="DPS_M", short="D", long="DPS Melee",   r=1.0, g=0.2, b=0.2  },
    { key="DPS_R", short="D", long="DPS a Rango", r=1.0, g=0.5, b=0.15 },
    { key="TANK",  short="T", long="Tank",        r=0.3, g=0.5, b=1.0  },
}
local DOT_SZ  = 10
local DOT_GAP = 2
-- Fila horizontal de labels: H D D T alineados sobre los dots
-- Los dots empiezan en x = MEMBER_BTN_W + 4 dentro del boton
-- En el sidePanel el scroll empieza en x=4, asi que offset total = 4 + MEMBER_BTN_W + 4
local DOTS_PANEL_X = 4 + MEMBER_BTN_W + 4  -- x en sidePanel donde empieza el primer dot
local LABEL_Y = MEMBER_PANEL_Y - 42         -- bajado 6px para no tapar botones de filtro

for di, rd in ipairs(ROLE_DEFS) do
    local lbl = sidePanel:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    local lx = DOTS_PANEL_X + (di-1)*(DOT_SZ+DOT_GAP)
    lbl:SetPoint("TOPLEFT", sidePanel, "TOPLEFT", lx, LABEL_Y)
    lbl:SetText(rd.short)
    lbl:SetTextColor(rd.r, rd.g, rd.b, 1)
end

-- ── Botones Filtrar + dropdown de rol ───────────────────────────
local FILTER_Y    = MEMBER_PANEL_Y - 22
local filterRole  = nil   -- nil = sin filtro activo
local filterDDOpen = false

-- Dropdown de seleccion de rol para filtrar
local filterDD = CreateFrame("Frame", "RaidMarkFilterDD", sidePanel)
filterDD:SetWidth(90); filterDD:SetHeight(4*20+8)
filterDD:SetFrameStrata("FULLSCREEN_DIALOG"); filterDD:SetFrameLevel(170)
filterDD:SetBackdrop({
    bgFile="Interface\\Buttons\\WHITE8X8",
    edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize=8, insets={left=2,right=2,top=2,bottom=2}
})
filterDD:SetBackdropColor(0.04,0.04,0.05,1)
filterDD:SetBackdropBorderColor(0.6,0.5,0.2,1)
filterDD:EnableMouse(true); filterDD:Hide()

local FILTER_OPTS = {
    { key="HEAL",  label="Healer",   r=0.2,g=1.0,b=0.3  },
    { key="DPS_M", label="DPS Melee",r=1.0,g=0.2,b=0.2  },
    { key="DPS_R", label="DPS Rang", r=1.0,g=0.5,b=0.15 },
    { key="TANK",  label="Tank",     r=0.3,g=0.5,b=1.0  },
}
local filterVBtn  -- referencia al boton v para actualizar su label

for i, opt in ipairs(FILTER_OPTS) do
    local row = CreateFrame("Button", nil, filterDD)
    row:SetHeight(20); row:SetWidth(82)
    row:SetPoint("TOPLEFT", filterDD, "TOPLEFT", 4, -(4+(i-1)*20))
    local rhl = row:CreateTexture(nil,"HIGHLIGHT")
    rhl:SetAllPoints(row); rhl:SetTexture(1,1,1,0.15)
    local rfs = row:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    rfs:SetPoint("LEFT",row,"LEFT",4,0)
    rfs:SetText(opt.label)
    rfs:SetTextColor(opt.r,opt.g,opt.b,1)
    row:EnableMouse(true)
    local capturedKey   = opt.key
    local capturedLabel = opt.label
    row:SetScript("OnClick", function()
        filterRole = capturedKey
        if filterVBtn then
            filterVBtn.labelText:SetText(capturedLabel)
        end
        filterDD:Hide()
    end)
end

-- Boton "v" (abre dropdown de rol)
-- Helper para crear botones compactos en el panel
local function makePanelBtn(lbl, w, x, y, r, g, b)
    local btn = CreateFrame("Button", nil, sidePanel)
    btn:SetWidth(w); btn:SetHeight(18)
    btn:SetPoint("TOPLEFT", sidePanel, "TOPLEFT", x, y)
    btn:SetBackdrop({
        bgFile="Interface\\Buttons\\WHITE8X8",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize=5, insets={left=1,right=1,top=1,bottom=1}
    })
    btn:SetBackdropColor(0.08,0.08,0.10,1)
    btn:SetBackdropBorderColor(r or 0.5, g or 0.42, b or 0.22, 0.9)
    local fs = btn:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    fs:SetPoint("CENTER",btn,"CENTER",0,0)
    fs:SetText(lbl)
    fs:SetTextColor(r or 0.8, g or 0.8, b or 0.6, 1)
    btn.labelText = fs
    btn:EnableMouse(true)
    return btn
end

local FBTN_X  = 8    -- x inicio
local FBTN_W  = 28   -- ancho boton v
local FBTN_W2 = 46   -- ancho boton Filtrar
local FBTN_W3 = 52   -- ancho boton Reset P
local FBTN_GAP = 3

-- Boton [v] - abre dropdown de rol
local vBtn = makePanelBtn("v", FBTN_W, FBTN_X, FILTER_Y)
filterVBtn = vBtn
vBtn:SetScript("OnClick", function()
    if filterDD:IsVisible() then
        filterDD:Hide()
    else
        filterDD:ClearAllPoints()
        filterDD:SetPoint("TOPLEFT", vBtn, "BOTTOMLEFT", 0, -2)
        filterDD:Show()
    end
end)
vBtn:SetScript("OnEnter", function()
    GameTooltip:SetOwner(vBtn,"ANCHOR_LEFT")
    GameTooltip:SetText("Seleccionar rol para filtrar")
    GameTooltip:Show()
end)
vBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Boton [Filtrar] - aplica el filtro
local filterBtn = makePanelBtn("Filtrar", FBTN_W2,
    FBTN_X + FBTN_W + FBTN_GAP, FILTER_Y, 0.5, 0.7, 1)
filterBtn:SetScript("OnClick", function()
    MF.activeFilter = filterRole
    MF.RebuildRosterButtons()
end)
filterBtn:SetScript("OnEnter", function()
    GameTooltip:SetOwner(filterBtn,"ANCHOR_LEFT")
    if filterRole then
        GameTooltip:SetText("Filtrar por: "..filterRole)
        GameTooltip:AddLine("Los del rol seleccionado apareceran primero", 0.7,0.7,0.7,true)
    else
        GameTooltip:SetText("Selecciona un rol en [v] primero", 0.8,0.6,0.3,true)
    end
    GameTooltip:Show()
end)
filterBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Boton [Reset P] - regresa todos los raiders del lienzo al panel
local FBTN_W3   = 52   -- ancho boton Reset P
local FBTN_W4   = 56   -- ancho boton Enviar Roles
local FBTN_W5   = 52   -- ancho boton Sync Rol
local resetPX   = FBTN_X + FBTN_W + FBTN_GAP + FBTN_W2 + FBTN_GAP
local resetPBtn = makePanelBtn("Reset P", FBTN_W3, resetPX, FILTER_Y, 1, 0.5, 0.2)
resetPBtn:SetScript("OnClick", function()
    if not RM.Permissions.IsRL() then return end
    local toRemove = {}
    for iconId, ic in pairs(RM.state.placedIcons) do
        if ic.iconType and string.sub(ic.iconType, 1, 7) == "MEMBER_" then
            table.insert(toRemove, iconId)
        end
    end
    for _, iconId in ipairs(toRemove) do
        RM.Icons.ApplyRemove(iconId)
        RM.Network.SendRemove(iconId)
    end
    if MF.ConsoleMsg then MF.ConsoleMsg("Raiders devueltos al panel.", 0.8, 0.9, 1) end
end)
resetPBtn:SetScript("OnEnter", function()
    GameTooltip:SetOwner(resetPBtn,"ANCHOR_LEFT")
    GameTooltip:SetText("Reset Posiciones")
    GameTooltip:AddLine("Devuelve todos los raiders del lienzo al panel", 0.7,0.7,0.7,true)
    GameTooltip:Show()
end)
resetPBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Boton [Enviar Roles] - solo Assist puede usarlo (manda roles al RL)
local enviarRolesX = resetPX + FBTN_W3 + FBTN_GAP
local enviarRolesBtn = makePanelBtn("Env.Rol", FBTN_W4, enviarRolesX, FILTER_Y, 0.3, 0.8, 0.5)
local enviarRolesLastSent = 0  -- throttle para no saturar canal

local function updateEnviarRolesBtn()
    -- Solo Assist activo (CanPlace pero no RL)
    local isActiveAssist = RM.Permissions.CanPlace() and not RM.Permissions.IsRL()
    if isActiveAssist then
        enviarRolesBtn:SetAlpha(1.0)
        enviarRolesBtn:EnableMouse(true)
        enviarRolesBtn.labelText:SetTextColor(0.3, 0.9, 0.5, 1)
    else
        enviarRolesBtn:SetAlpha(0.35)
        enviarRolesBtn:EnableMouse(false)
        enviarRolesBtn.labelText:SetTextColor(0.4, 0.4, 0.4, 1)
    end
end
MF.UpdateEnviarRolesBtn = updateEnviarRolesBtn
updateEnviarRolesBtn()

enviarRolesBtn:SetScript("OnClick", function()
    -- Solo Assist activo (CanPlace pero no RL)
    if not RM.Permissions.CanPlace() or RM.Permissions.IsRL() then
        MF.ConsoleMsg("Solo los Asistentes pueden enviar roles.", 1,0.4,0.2)
        return
    end
    -- Throttle: solo 1 envio cada 15 segundos
    local now = GetTime()
    if (now - enviarRolesLastSent) < 15 then
        local remaining = math.ceil(15 - (now - enviarRolesLastSent))
        MF.ConsoleMsg("Espera "..remaining.."s antes de enviar roles de nuevo.", 1,0.6,0.2)
        return
    end
    -- Recopilar roles locales
    local queue = {}
    for name, role in pairs(RM.state.memberRoles) do
        if name and name ~= "" and role then
            table.insert(queue, {name=name, role=role})
        end
    end
    local count = table.getn(queue)
    if count == 0 then
        MF.ConsoleMsg("No tienes roles asignados para enviar.", 0.7,0.7,0.7)
        return
    end
    enviarRolesLastSent = now
    MF.ConsoleMsg("Enviando "..count.." roles al RL...", 0.4, 0.9, 0.5)
    -- Enviar con delay de 0.1s entre mensajes para no saturar canal
    local idx = 1
    local elapsed2 = 0
    local propFrame = CreateFrame("Frame","RaidMarkRoleProposeFrame")
    propFrame:SetScript("OnUpdate", function()
        elapsed2 = elapsed2 + arg1
        if elapsed2 >= 0.1 then
            elapsed2 = 0
            if idx <= table.getn(queue) then
                local entry = queue[idx]
                RM.Network.SendRaw("ROLEPROPOSE;" .. entry.name .. ";" .. entry.role)
                idx = idx + 1
            else
                propFrame:SetScript("OnUpdate", nil)
                MF.ConsoleMsg("Propuesta de "..count.." roles enviada.", 0.4, 0.9, 0.5)
            end
        end
    end)
end)
enviarRolesBtn:SetScript("OnEnter", function()
    GameTooltip:SetOwner(enviarRolesBtn,"ANCHOR_LEFT")
    GameTooltip:SetText("Enviar Roles al RL")
    GameTooltip:AddLine("Propone tus roles al RL (solo rellena huecos)", 0.7,0.7,0.7,true)
    GameTooltip:AddLine("Solo disponible para Asistentes", 0.6,0.8,0.6,true)
    GameTooltip:Show()
end)
enviarRolesBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Boton [Sync Rol] - solo RL puede usarlo (incluye roles en el proximo sync)
local syncRolX   = enviarRolesX + FBTN_W4 + FBTN_GAP
local syncRolBtn = makePanelBtn("Sync Rol", FBTN_W5, syncRolX, FILTER_Y, 0.4, 0.7, 1)
MF.syncRolBtn    = syncRolBtn

local function updateSyncRolBtn()
    if RM.Permissions.IsRL() then
        syncRolBtn:SetAlpha(1.0)
        syncRolBtn:EnableMouse(true)
        syncRolBtn.labelText:SetTextColor(0.4, 0.8, 1, 1)
    else
        syncRolBtn:SetAlpha(0.35)
        syncRolBtn:EnableMouse(false)
        syncRolBtn.labelText:SetTextColor(0.4, 0.4, 0.4, 1)
    end
end
MF.UpdateSyncRolBtn = updateSyncRolBtn
updateSyncRolBtn()

syncRolBtn:SetScript("OnClick", function()
    if not RM.Permissions.IsRL() then return end
    -- Mandar todos los roles via RosterSync
    RM.Network.SendAllRoles()
    MF.ConsoleMsg("Roles sincronizados al raid.", 0.4, 1, 0.6)
end)
syncRolBtn:SetScript("OnEnter", function()
    GameTooltip:SetOwner(syncRolBtn,"ANCHOR_LEFT")
    GameTooltip:SetText("Sync Roles")
    GameTooltip:AddLine("Envia todos los roles asignados al raid", 0.7,0.7,0.7,true)
    GameTooltip:AddLine("Solo disponible para el RL", 0.6,0.8,1,true)
    GameTooltip:Show()
end)
syncRolBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Inicializar filtro activo
MF.activeFilter = nil

-- ── Botones de auto-asignacion de rol (debajo del scroll) ───────
-- Posicion: debajo de memberScrollFrame
-- memberScrollFrame esta en MEMBER_PANEL_Y - 20, altura SAFE_SCROLL_H
local ASSIGN_BTN_Y = MEMBER_PANEL_Y - 52 - SAFE_SCROLL_H - 6
local ASSIGN_BTN_W = math.floor((PANEL_W - 16) / 5) - 2
local ASSIGN_BTN_H = 20

-- Estado de asignacion automatica
local assignActive   = false  -- true mientras corre el contador
local totalActive    = false  -- true mientras corre auto-total
local assignRole     = nil    -- rol que se esta asignando
local assignTimer    = 0
local assignDuration = 10
local assignResponders = {}   -- {name=true} de raiders que respondieron

local ASSIGN_DEFS = {
    { key="HEAL",  label="Healer", cmd="1", r=0.2, g=1.0, b=0.3  },
    { key="DPS_M", label="DD M",   cmd="2", r=1.0, g=0.2, b=0.2  },
    { key="DPS_R", label="DD R",   cmd="3", r=1.0, g=0.5, b=0.15 },
    { key="TANK",  label="Tank",   cmd="4", r=0.3, g=0.5, b=1.0  },
    { key="EDIT",  label="Edit",   cmd=nil, r=0.7, g=0.7, b=0.7  },
}

local assignBtns = {}

for i, def in ipairs(ASSIGN_DEFS) do
    local abtn = CreateFrame("Button", nil, sidePanel)
    abtn:SetWidth(ASSIGN_BTN_W)
    abtn:SetHeight(ASSIGN_BTN_H)
    abtn:SetPoint("BOTTOMLEFT", sidePanel, "BOTTOMLEFT",
        8 + (i-1)*(ASSIGN_BTN_W+2), ASSIGN_BTN_H + 10)
    abtn:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 6, insets={left=2,right=2,top=2,bottom=2}
    })
    abtn:SetBackdropColor(0.08, 0.08, 0.10, 1)
    abtn:SetBackdropBorderColor(def.r*0.6, def.g*0.6, def.b*0.6, 1)
    local afs = abtn:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    afs:SetPoint("CENTER",abtn,"CENTER",0,0)
    afs:SetText(def.label)
    afs:SetTextColor(def.r, def.g, def.b, 1)
    abtn.labelFs = afs
    abtn:EnableMouse(true)

    local capturedDef = def
    abtn:SetScript("OnClick", function()
        if RM.state.offlineMode then
            MF.ConsoleOffline("Estas en modo offline! Network deshabilitado.")
            return
        end
        if not RM.Permissions.CanPlace() then
            MF.ConsoleMsg("Solo el RL o Asistente puede usar auto-asignar.", 1,0.4,0.2)
            return
        end
        if assignActive or totalActive or assignCooldown > 0 then
            if assignCooldown > 0 then
                MF.ConsoleMsg("Auto-asignar bloqueado ("..math.ceil(assignCooldown).."s).", 1,0.6,0.2)
            end
            return
        end
        if capturedDef.key == "EDIT" then return end
        if GetNumRaidMembers() == 0 then
            if MF.ConsoleMsg then MF.ConsoleMsg("Debes estar en un raid para usar auto-asignar.", 1,0.5,0.2) end
            return
        end

        assignActive     = true
        -- Bloquear a todos en el raid durante la duracion del assign
        RM.Network.SendRaw("ASSIGN_COOLDOWN;15")
        assignRole       = capturedDef.key
        assignTimer      = 0
        assignResponders = {}

        -- Mensaje inicial por /rw
        local roleNames = {HEAL="Healers",DPS_M="DPS Melee",DPS_R="DPS a Rango",TANK="Tanks"}
        local roleName  = roleNames[capturedDef.key] or capturedDef.key
        SendChatMessage("Todos los "..roleName.." escriban ["..capturedDef.cmd.."] en /raid", "RAID_WARNING")

        -- Bloquear todos los botones durante la sesion
        for _, b in ipairs(assignBtns) do
            b:SetAlpha(0.4)
        end
        abtn:SetAlpha(1.0)
        abtn:SetBackdropBorderColor(1, 1, 0, 1)

        -- Countdown por /rw y lectura de respuestas
        local countFrame = CreateFrame("Frame")
        local elapsed = 0
        local lastTick = assignDuration + 1

        countFrame:SetScript("OnUpdate", function()
            elapsed = elapsed + arg1
            assignTimer = elapsed
            local remaining = math.floor(assignDuration - elapsed)

            -- Spam solo en los ultimos 5 segundos
            if remaining < lastTick and remaining >= 0 then
                lastTick = remaining
                if remaining > 0 and remaining <= 3 then
                    SendChatMessage(remaining.."...", "RAID_WARNING")
                elseif remaining == 0 then
                    SendChatMessage("Tiempo!", "RAID_WARNING")
                end
            end

            if elapsed >= assignDuration then
                -- Fin de la sesion
                assignActive   = false
                assignRole     = nil
                assignCooldown = ASSIGN_COOLDOWN_TIME
                RM.Network.SendRaw("ASSIGN_COOLDOWN;10")
                countFrame:SetScript("OnUpdate", nil)
                for _, b in ipairs(assignBtns) do
                    b:SetAlpha(1.0)
                    b:SetBackdropBorderColor(
                        ASSIGN_DEFS[1].r*0.6, ASSIGN_DEFS[1].g*0.6, ASSIGN_DEFS[1].b*0.6, 1)
                end
                abtn:SetBackdropBorderColor(
                    capturedDef.r*0.6, capturedDef.g*0.6, capturedDef.b*0.6, 1)
                MF.RebuildRosterButtons()
                SendChatMessage("Asignacion de "..roleName.." completada.", "RAID_WARNING")
            end
        end)
    end)

    abtn:SetScript("OnEnter", function()
        if capturedDef.key == "EDIT" then
            GameTooltip:SetOwner(abtn,"ANCHOR_TOP")
            GameTooltip:SetText("Edicion manual (proximamente)")
            GameTooltip:Show()
            return
        end
        local roleNames = {HEAL="Healers",DPS_M="DPS Melee",DPS_R="DPS a Rango",TANK="Tanks"}
        local cmd = capturedDef.cmd
        GameTooltip:SetOwner(abtn,"ANCHOR_TOP")
        GameTooltip:SetText("Auto-asignar: "..(roleNames[capturedDef.key] or ""))
        GameTooltip:AddLine("Los raiders escriben ["..cmd.."] en /raid", 0.8,0.8,0.5,true)
        GameTooltip:AddLine("Cuenta regresiva de "..assignDuration.." segundos", 0.7,0.7,0.7,true)
        GameTooltip:Show()
    end)
    abtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    table.insert(assignBtns, abtn)
end

-- ── Botón AUTO-TOTAL ──────────────────────────────────────────────
local autoTotalBtn = CreateFrame("Button", nil, sidePanel)
autoTotalBtn:SetWidth(PANEL_W - 16)
autoTotalBtn:SetHeight(ASSIGN_BTN_H)
autoTotalBtn:SetPoint("BOTTOMLEFT", sidePanel, "BOTTOMLEFT", 8, 6)
autoTotalBtn:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 6, insets={left=2,right=2,top=2,bottom=2}
})
autoTotalBtn:SetBackdropColor(0.08, 0.05, 0.12, 1)
autoTotalBtn:SetBackdropBorderColor(0.8, 0.6, 1, 1)
local atfs = autoTotalBtn:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
atfs:SetPoint("CENTER",autoTotalBtn,"CENTER",0,0)
atfs:SetText("Auto-Total (20s)")
atfs:SetTextColor(0.85, 0.6, 1, 1)
autoTotalBtn:EnableMouse(true)

local TOTAL_DURATION = 20

autoTotalBtn:SetScript("OnClick", function()
    if not RM.Permissions.CanPlace() then
        MF.ConsoleMsg("Solo el RL o Asistente puede usar auto-total.", 1,0.4,0.2)
        return
    end
    if assignActive or totalActive or assignCooldown > 0 then
        if assignCooldown > 0 then
            MF.ConsoleMsg("Auto-asignar bloqueado ("..math.ceil(assignCooldown).."s).", 1,0.6,0.2)
        end
        return
    end
    if GetNumRaidMembers() == 0 then
        if MF.ConsoleMsg then MF.ConsoleMsg("Debes estar en un raid.", 1,0.5,0.2) end
        return
    end
    if RM.state.offlineMode then
        MF.ConsoleOffline("Estas en modo offline! Network deshabilitado.")
        return
    end
    totalActive      = true
    -- Bloquear a todos en el raid durante la duracion del total
    RM.Network.SendRaw("ASSIGN_COOLDOWN;25")
    assignResponders = {}
    -- NO limpiar roles previos: las respuestas sobreescriben individualmente

    SendChatMessage("=== ASIGNACION DE ROLES ===", "RAID_WARNING")
    SendChatMessage("Escribe tu numero: 1=Healer // 2=DPS Melee // 3=DPS Rango // 4=Tank", "RAID_WARNING")

    -- Bloquear todos los assign btns
    for _, b in ipairs(assignBtns) do b:SetAlpha(0.4) end
    autoTotalBtn:SetBackdropBorderColor(1, 1, 0, 1)

    local elapsed   = 0
    local lastTick2 = TOTAL_DURATION + 1
    local totalRespondedAll = {}  -- todos los que respondieron

    local totalFrame = CreateFrame("Frame")
    totalFrame:SetScript("OnUpdate", function()
        elapsed = elapsed + arg1
        local remaining = math.floor(TOTAL_DURATION - elapsed)

        -- Spam: 19-10 y 4-0
        if remaining < lastTick2 and remaining >= 0 then
            lastTick2 = remaining
            local shouldSpam = remaining <= 3
            if shouldSpam and remaining > 0 then
                SendChatMessage(remaining.."...", "RAID_WARNING")
            elseif remaining == 0 then
                -- Recuento final
                local total  = GetNumRaidMembers()
                local responded = 0
                for _ in pairs(totalRespondedAll) do responded = responded + 1 end
                SendChatMessage("Tiempo! "..responded.."/"..total.." respondieron.", "RAID_WARNING")
            end
        end

        if elapsed >= TOTAL_DURATION then
            totalActive    = false
            assignCooldown = ASSIGN_COOLDOWN_TIME
            RM.Network.SendRaw("ASSIGN_COOLDOWN;10")
            totalFrame:SetScript("OnUpdate", nil)
            for _, b in ipairs(assignBtns) do b:SetAlpha(1.0) end
            autoTotalBtn:SetBackdropBorderColor(0.8, 0.6, 1, 1)
            MF.RebuildRosterButtons()
        end
    end)

    -- Guardar ref para que el listener pueda usar totalRespondedAll
    MF._totalRespondedAll = totalRespondedAll
    MF._totalActive       = function() return totalActive end
end)

autoTotalBtn:SetScript("OnEnter", function()
    GameTooltip:SetOwner(autoTotalBtn,"ANCHOR_TOP")
    GameTooltip:SetText("Auto-asignar todos los roles a la vez")
    GameTooltip:AddLine("20 segundos | 1=H 2=DDM 3=DDR 4=T", 0.7,0.7,0.7,true)
    GameTooltip:Show()
end)
autoTotalBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- ── Leer respuestas del chat de raid ─────────────────────────────
-- Registramos CHAT_MSG_RAID en el eventFrame principal
-- Guardamos la funcion para que core.lua la llame
-- Mapa de numeros a roles para auto-total
local CMD_TO_ROLE = { ["1"]="HEAL", ["2"]="DPS_M", ["3"]="DPS_R", ["4"]="TANK" }

local function isInRaid(name)
    if RM.Roster and RM.Roster.members and RM.Roster.members[name] then return true end
    for i=1,40 do
        local n = GetRaidRosterInfo(i)
        if n == name then return true end
    end
    return false
end

function MF.OnRaidChat(msg, sender)
    if not msg or not sender then return end
    local trimmed = string.gsub(msg, "^%s*(.-)%s*$", "%1")

    -- Modo auto-total: acepta 1/2/3/4
    if totalActive and MF._totalRespondedAll then
        local role = CMD_TO_ROLE[trimmed]
        if role and isInRaid(sender) and not MF._totalRespondedAll[sender] then
            MF._totalRespondedAll[sender] = true
            RM.state.memberRoles[sender]  = role
            if RaidMarkDB then RaidMarkDB.memberRoles = RM.state.memberRoles end
            RM.Network.SendRole(sender, role)
        end
        return
    end

    -- Modo single assign
    if not assignActive then return end
    local expected = nil
    for _, def in ipairs(ASSIGN_DEFS) do
        if def.key == assignRole then expected = def.cmd; break end
    end
    if not expected then return end
    if trimmed == expected and isInRaid(sender) and not assignResponders[sender] then
        assignResponders[sender] = true
        RM.state.memberRoles[sender] = assignRole
        if RaidMarkDB then RaidMarkDB.memberRoles = RM.state.memberRoles end
        RM.Network.SendRole(sender, assignRole)
    end
end

-- Iconos de rol offline (reutiliza TGAs existentes)
-- Iconos offline: cuadrados de color solido (sin TGA)
-- Colores coinciden con los checkboxes de auto-assign
-- r,g,b = color del cuadrado en el lienzo
local OFFLINE_ROLE_ICONS = {
    { type="OFFLINE_TANK",  label="Tank",     r=0.3,  g=0.5,  b=1.0,  a=1 },
    { type="OFFLINE_HEAL",  label="Healer",   r=0.2,  g=1.0,  b=0.3,  a=1 },
    { type="OFFLINE_DPSM",  label="DPS Melee",r=1.0,  g=0.2,  b=0.2,  a=1 },
    { type="OFFLINE_DPSR",  label="DPS Rang", r=1.0,  g=0.5,  b=0.15, a=1 },
    { type="OFFLINE_EDIT",  label="Edit",     r=0.65, g=0.65, b=0.65, a=1 },
}
-- Registrar en tablas globales (textura=WHITE8X8 tintado, tamaño=clase)
for _, od in ipairs(OFFLINE_ROLE_ICONS) do
    RM.ICON_TEXTURE[od.type] = "Interface\\Buttons\\WHITE8X8"
    RM.ICON_SIZE[od.type]    = 24
    -- Guardar color para aplicar en createIconFrame
    if not RM.OFFLINE_ICON_COLOR then RM.OFFLINE_ICON_COLOR = {} end
    RM.OFFLINE_ICON_COLOR[od.type] = {od.r, od.g, od.b, od.a}
end

-- Funcion para saber si un tipo es offline-rol
local OFFLINE_TYPES = {}
for _, od in ipairs(OFFLINE_ROLE_ICONS) do OFFLINE_TYPES[od.type] = true end
function RM.IsOfflineRoleIcon(t) return OFFLINE_TYPES[t] == true end

-- Botones de miembros (se reconstruyen con el roster)
local memberButtons = {}

function MF.RebuildRosterButtons()
    for _, btn in ipairs(memberButtons) do btn:Hide() end
    memberButtons = {}

    -- Modo offline: mostrar iconos de rol en lugar de raiders reales
    if RM.state.offlineMode then
        for i, od in ipairs(OFFLINE_ROLE_ICONS) do
            local yOff = -(i-1) * (MEMBER_BTN_H + 2)
            local btn = CreateFrame("Button", nil, memberContent)
            btn:SetWidth(MEMBER_BTN_W); btn:SetHeight(MEMBER_BTN_H)
            btn:SetPoint("TOPLEFT", memberContent, "TOPLEFT", 0, yOff)
            local fbg = btn:CreateTexture(nil,"BACKGROUND")
            fbg:SetAllPoints(btn); fbg:SetTexture(od.r*0.15, od.g*0.15, od.b*0.15, 0.9)
            -- Cuadrado de color a la izquierda
            local icn = btn:CreateTexture(nil,"ARTWORK")
            icn:SetWidth(14); icn:SetHeight(14)
            icn:SetPoint("LEFT",btn,"LEFT",4,0)
            icn:SetTexture("Interface\\Buttons\\WHITE8X8")
            icn:SetVertexColor(od.r, od.g, od.b, 1)
            local nm = btn:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
            BigFont(nm,10)
            nm:SetPoint("LEFT",btn,"LEFT",22,0)
            nm:SetText(od.label)
            nm:SetTextColor(od.r, od.g, od.b, 1)
            local hl = btn:CreateTexture(nil,"HIGHLIGHT")
            hl:SetAllPoints(btn); hl:SetTexture(1,1,1,0.15)
            btn:EnableMouse(true)
            local capturedType = od.type
            local capturedTex  = od.tex
            btn:SetScript("OnClick", function()
                MF.selectedIconType   = capturedType
                MF.selectedMemberName = nil
                MF.HighlightSelected(btn)
            end)
            local capturedLabel = od.label
            btn:SetScript("OnEnter", function()
                GameTooltip:SetOwner(btn,"ANCHOR_LEFT")
                GameTooltip:SetText("Colocar: "..capturedLabel)
                GameTooltip:AddLine("Icono de rol (modo offline)", 0.7,0.7,0.7,true)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            table.insert(memberButtons, btn)
        end
        memberContent:SetHeight(math.max(1, table.getn(OFFLINE_ROLE_ICONS) * (MEMBER_BTN_H+2)))
        return
    end

    local members = RM.Roster.GetSortedList()
    local totalH  = 0
    local visibleIndex = 1

    -- Aplicar filtro: primero los del rol filtrado, luego los demas
    local activeFilter = MF.activeFilter
    if activeFilter then
        local filtered   = {}
        local unfiltered = {}
        for _, data in ipairs(members) do
            if RM.state.memberRoles[data.name] == activeFilter then
                table.insert(filtered, data)
            else
                table.insert(unfiltered, data)
            end
        end
        members = {}
        for _, d in ipairs(filtered)   do table.insert(members, d) end
        for _, d in ipairs(unfiltered) do table.insert(members, d) end
    end

    for i, data in ipairs(members) do
        -- FILTRO: Solo crear el botón si NO está en el mapa
        if not RM.Icons.IsPlayerPlaced(data.name) then
            local yOff = -(visibleIndex-1) * (MEMBER_BTN_H + 2)

            local btn = CreateFrame("Button", nil, memberContent)
            btn:SetWidth(MEMBER_BTN_W)
            btn:SetHeight(MEMBER_BTN_H)
            btn:SetPoint("TOPLEFT", memberContent, "TOPLEFT", 0, yOff)

            -- Fondo
            local fbg = btn:CreateTexture(nil, "BACKGROUND")
            fbg:SetAllPoints(btn)
            local r,g,b = RM.Roster.GetColor(data.classFile)
            fbg:SetTexture(r*0.3, g*0.3, b*0.3, 0.7)

            -- Icono de clase pequeno
            local icn = btn:CreateTexture(nil, "ARTWORK")
            icn:SetWidth(16)
            icn:SetHeight(16)
            icn:SetPoint("LEFT", btn, "LEFT", 2, 0)
            icn:SetTexture(RM.Roster.GetTexturePath(data.classFile))

            -- Nombre
            local nm = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            BigFont(nm, 10)
            nm:SetPoint("LEFT", btn, "LEFT", 22, 0)
            nm:SetText(data.name)
            nm:SetTextColor(r, g, b, 1)

            -- Highlight
            local hl = btn:CreateTexture(nil, "HIGHLIGHT")
            hl:SetAllPoints(btn)
            hl:SetTexture(1, 1, 1, 0.15)

            btn:EnableMouse(true)

            -- Captura local para evitar el bug de closure en Lua 5.0
            local memberName      = data.name
            local memberClassFile = data.classFile

            btn:SetScript("OnClick", function()
                MF.selectedIconType   = "MEMBER_" .. memberClassFile
                MF.selectedMemberName = memberName
                RM.ICON_TEXTURE["MEMBER_" .. memberClassFile] =
                    RM.Roster.GetTexturePath(memberClassFile)
                RM.ICON_SIZE["MEMBER_" .. memberClassFile] = 24
                MF.HighlightSelected(btn)
            end)

            btn:SetScript("OnEnter", function()
                GameTooltip:SetOwner(btn, "ANCHOR_LEFT")
                GameTooltip:SetText("Colocar: " .. memberName)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

            -- Role dots: hijos del btn -> desaparecen cuando btn se oculta
            for di, rd in ipairs(ROLE_DEFS) do
                local dot = CreateFrame("Button", nil, btn)
                dot:SetWidth(DOT_SZ); dot:SetHeight(DOT_SZ)
                -- Anclado a la derecha del btn, centrado verticalmente
                dot:SetPoint("LEFT", btn, "RIGHT", 2 + (di-1)*(DOT_SZ+DOT_GAP), 0)
                dot:SetFrameLevel(btn:GetFrameLevel() + 2)
                dot:EnableMouse(true)

                local dotTex = dot:CreateTexture(nil,"ARTWORK")
                dotTex:SetAllPoints(dot)
                dot:SetBackdrop({
                    bgFile   = "Interface\\Buttons\\WHITE8X8",
                    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                    edgeSize = 4, insets={left=1,right=1,top=1,bottom=1}
                })

                local capturedName = memberName
                local capturedKey  = rd.key
                local capturedLong = rd.long
                local cr, cg, cb   = rd.r, rd.g, rd.b

                local function refreshDot()
                    if RM.state.memberRoles[capturedName] == capturedKey then
                        dotTex:SetTexture(cr, cg, cb, 1)
                        dot:SetBackdropBorderColor(0, 0, 0, 1)
                    else
                        dotTex:SetTexture(0.05, 0.05, 0.05, 1)
                        dot:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
                    end
                end
                refreshDot()

                dot:SetScript("OnClick", function()
                    if not RM.Permissions.CanPlace() then return end
                    if RM.state.memberRoles[capturedName] == capturedKey then
                        RM.state.memberRoles[capturedName] = nil
                    else
                        RM.state.memberRoles[capturedName] = capturedKey
                    end
                    if RaidMarkDB then RaidMarkDB.memberRoles = RM.state.memberRoles end
                    MF.RebuildRosterButtons()
                end)
                dot:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(dot, "ANCHOR_LEFT")
                    GameTooltip:SetText(capturedName.." - "..capturedLong)
                    if RM.state.memberRoles[capturedName] == capturedKey then
                        GameTooltip:AddLine("Click para quitar rol", 0.8,0.4,0.4,true)
                    else
                        GameTooltip:AddLine("Click para asignar rol", 0.4,0.8,0.4,true)
                    end
                    GameTooltip:Show()
                end)
                dot:SetScript("OnLeave", function() GameTooltip:Hide() end)
            end

            table.insert(memberButtons, btn)
            totalH = totalH + MEMBER_BTN_H + 2
            visibleIndex = visibleIndex + 1
        end
    end

    memberContent:SetHeight(math.max(1, totalH))
end
-- -- Highlight del boton seleccionado ----------------------------
MF.lastSelectedBtn = nil

function MF.HighlightSelected(btn)
    -- Quitar highlight del anterior
    if MF.lastSelectedBtn and MF.lastSelectedBtn ~= btn then
        MF.lastSelectedBtn:SetAlpha(1.0)
    end
    btn:SetAlpha(0.6)
    MF.lastSelectedBtn = btn
end

-- ================================================================
--  TOOLBAR GRAFICA
--  Layout izq→der: [v Encounter] [Limpiar]  |  derecha: [Assist] [Cerrar]
-- ================================================================

local function makeToolbarBtn(label, width, parent)
    local btn = CreateFrame("Button", nil, parent or toolbar)
    btn:SetWidth(width)
    btn:SetHeight(24)
    btn:SetFrameLevel(toolbar:GetFrameLevel() + 1)
    btn:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets   = { left=2, right=2, top=2, bottom=2 },
    })
    btn:SetBackdropColor(0.15, 0.12, 0.06, 0.95)
    btn:SetBackdropBorderColor(0.5, 0.42, 0.22, 0.9)
    local hl = btn:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints(btn)
    hl:SetTexture(1, 1, 1, 0.10)
    local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    BigFont(fs, 10)
    fs:SetPoint("CENTER", btn, "CENTER", 0, 0)
    fs:SetText(label)
    btn.labelText = fs
    btn:EnableMouse(true)
    return btn
end

-- -- Dropdown frame con Scroll y Categorías ----------------------
local dropdownFrame = CreateFrame("Frame", "RaidMarkDropdown", UIParent)
dropdownFrame:SetWidth(180) -- Un poco más ancho para acomodar la barra de scroll
dropdownFrame:SetHeight(300) -- Altura fija máxima para el menú
dropdownFrame:SetFrameStrata("TOOLTIP")
dropdownFrame:SetFrameLevel(100)
dropdownFrame:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 10,
    insets   = { left=3, right=3, top=3, bottom=3 },
})
dropdownFrame:SetBackdropColor(0.08, 0.07, 0.04, 0.97)
dropdownFrame:SetBackdropBorderColor(0.5, 0.42, 0.22, 1)
dropdownFrame:Hide()

-- Contenedor con Scroll
local dropScrollFrame = CreateFrame("ScrollFrame", "RM_DropScroll", dropdownFrame, "UIPanelScrollFrameTemplate")
dropScrollFrame:SetPoint("TOPLEFT", 8, -8)
dropScrollFrame:SetPoint("BOTTOMRIGHT", -26, 8) -- Espacio para la barra de scroll

local dropScrollChild = CreateFrame("Frame", nil, dropScrollFrame)
dropScrollChild:SetWidth(140)
dropScrollChild:SetHeight(1)
dropScrollFrame:SetScrollChild(dropScrollChild)

local dropItems = {}

local function closeDropdown()
    dropdownFrame:Hide()
end

local function openDropdown(anchorBtn)
    if dropdownFrame:IsVisible() then closeDropdown() return end
    
    -- Limpiar botones anteriores
    for _, item in ipairs(dropItems) do item:Hide() end
    dropItems = {}

    if not RaidMark_Maps then
        DEFAULT_CHAT_FRAME:AddMessage("RaidMark: maps.lua no cargado.")
        return
    end

    local yOffset = 0
    local ITEM_H = 20
    local raidsOrder = {"AQ40", "Naxxramas", "BWL", "MC"}

    for _, raidName in ipairs(raidsOrder) do
        -- Cabecera de Categoría
        local header = CreateFrame("Frame", nil, dropScrollChild)
        header:SetWidth(140)
        header:SetHeight(ITEM_H)
        header:SetPoint("TOPLEFT", dropScrollChild, "TOPLEFT", 0, yOffset)
        
        local headerText = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        BigFont(headerText, 10)
        headerText:SetPoint("LEFT", header, "LEFT", 2, 0)
        headerText:SetText("--- " .. raidName .. " ---")
        headerText:SetTextColor(1, 0.82, 0)
        
        table.insert(dropItems, header)
        yOffset = yOffset - ITEM_H

        -- Botones de jefes de esa categoría
        for key, def in pairs(RaidMark_Maps) do
            if def.raid == raidName then
                local item = CreateFrame("Button", nil, dropScrollChild)
                item:SetWidth(140)
                item:SetHeight(ITEM_H)
                item:SetPoint("TOPLEFT", dropScrollChild, "TOPLEFT", 5, yOffset)
                item:EnableMouse(true)

                local hl = item:CreateTexture(nil, "HIGHLIGHT")
                hl:SetAllPoints(item)
                hl:SetTexture(0.4, 0.35, 0.15, 0.5)

                local fs = item:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                BigFont(fs, 10)
                fs:SetPoint("LEFT", item, "LEFT", 5, 0)
                fs:SetText(def.label)
                fs:SetTextColor(0.9, 0.85, 0.6, 1)

                -- Captura local para el evento de clic
                local eKey   = key
                local eLabel = def.label
                item:SetScript("OnClick", function()
                    if RM.Permissions.CanPlace() then
                        RM.SetMap(eKey)
                        RM.Network.SendMapChange(eKey)
                        MF.encounterBtn.labelText:SetText("v  " .. eLabel)
                    end
                    closeDropdown()
                end)
                
                table.insert(dropItems, item)
                yOffset = yOffset - ITEM_H
            end
        end
        yOffset = yOffset - 5 -- Pequeño espacio extra después de cada grupo
    end

    dropScrollChild:SetHeight(math.abs(yOffset))

    dropdownFrame:ClearAllPoints()
    dropdownFrame:SetPoint("TOPLEFT", anchorBtn, "BOTTOMLEFT", 0, -2)
    dropdownFrame:Show()
end

-- Overlay invisible para cerrar dropdown al clickear fuera
local ddOverlay = CreateFrame("Frame", nil, UIParent)
ddOverlay:SetAllPoints(UIParent)
ddOverlay:SetFrameStrata("DIALOG")
ddOverlay:EnableMouse(true)
ddOverlay:Hide()
ddOverlay:SetScript("OnMouseDown", function() closeDropdown() end)
dropdownFrame:SetScript("OnShow", function() ddOverlay:Show() end)
dropdownFrame:SetScript("OnHide", function() ddOverlay:Hide() end)

-- -- Construir toolbar --------------------------------------------
local function buildToolbar()
    local xOff = 8
    -- [v Encounter]
    local encBtn = makeToolbarBtn("v  Encounter", 160)
    encBtn:SetPoint("LEFT", toolbar, "LEFT", xOff, 0)
    encBtn.labelText:SetTextColor(0.9, 0.85, 0.5, 1)
    encBtn:SetScript("OnClick", function() openDropdown(encBtn) end)
    encBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(encBtn, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Seleccionar mapa del encuentro")
        GameTooltip:Show()
    end)
    encBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    MF.encounterBtn = encBtn
    xOff = xOff + 168

    -- Separador
    local sep1 = toolbar:CreateTexture(nil, "ARTWORK")
    sep1:SetWidth(1); sep1:SetHeight(26)
    sep1:SetPoint("LEFT", toolbar, "LEFT", xOff, 0)
    sep1:SetTexture(0.4, 0.35, 0.2, 0.6)
    xOff = xOff + 10

    -- [Limpiar]
    local clearBtn = makeToolbarBtn("Limpiar", 100)
    clearBtn.labelText:SetTextColor(1, 0.4, 0.2, 1)
    clearBtn:SetPoint("LEFT", toolbar, "LEFT", xOff, 0)
    clearBtn:SetScript("OnClick", function()
        if RM.Permissions.CanPlace() then
            RM.ClearAll()
            RM.Network.SendClear()
            -- Limpiar flag de posicionamiento
            RM.state.lastLoadedPosi = nil
            if MF.syncPBtn then
                MF.syncPBtn:SetBackdropBorderColor(0.2, 0.7, 0.3, 1)
            end
        else
            if MF.ConsoleMsg then MF.ConsoleMsg("Sin permisos.", 1,0.3,0.3) end
        end
    end)
    clearBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(clearBtn, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Eliminar todos los iconos del mapa")
        GameTooltip:Show()
    end)
    clearBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    xOff = xOff + 108

-- [Sync] -- visible para todos, pide estado al RL
    local syncBtn = makeToolbarBtn("Sync", 80)
    syncBtn.labelText:SetTextColor(0.4, 0.8, 1, 1)
    MF.syncBtn = syncBtn  -- referencia para bloquear durante sync
    syncBtn:SetPoint("LEFT", toolbar, "LEFT", xOff, 0)
    syncBtn:SetScript("OnClick", function()
        if RM.state.offlineMode then
            MF.ConsoleOffline("Estas en modo offline! Network deshabilitado.")
            return
        end
        if RM.Permissions.IsRL() then
            -- Rebuild fresco desde API de WoW
            RM.Roster.Rebuild()
            
            -- LIMPIEZA DE FANTASMAS: Si están en el mapa pero ya no en la raid
            if RM.Roster.members then
                for iconId, data in pairs(RM.state.placedIcons) do
                    -- Si tiene label, es un miembro
                    if data.label and data.label ~= "" and not RM.Roster.members[data.label] then
                        RM.Icons.ApplyRemove(iconId)
                        RM.Network.SendRemove(iconId)
                    end
                end
            end

            -- Enviar estado del mapa + permisos
            RM.Network.SendSyncResponse()
            -- Enviar roster actualizado
            RM.Network.SendRosterSync()
            if MF.ConsoleMsg then MF.ConsoleMsg("Sync enviado al raid.", 0.4,1,0.4) end
        else
            -- Si no soy RL, pedir al RL
            RM.Network.SendSyncRequest()
        end
    end)
    syncBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(syncBtn, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Sincronizar mapa y miembros (RL) o pedir sync")
        GameTooltip:Show()
    end)
    syncBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    xOff = xOff + 88

    -- =========================================================
    -- ZONA DE PUNTERO: check + 4 indicadores de slot + consola
    -- =========================================================

    -- [Check Modo Puntero]
    local ptrCheck = CreateFrame("Button", nil, toolbar)
    ptrCheck:SetWidth(22)
    ptrCheck:SetHeight(22)
    ptrCheck:SetPoint("LEFT", toolbar, "LEFT", xOff, 0)
    ptrCheck:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets   = { left=2, right=2, top=2, bottom=2 },
    })
    ptrCheck:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
    ptrCheck:SetBackdropBorderColor(0.5, 0.42, 0.22, 0.9)
    local ptrCheckMark = ptrCheck:CreateTexture(nil, "OVERLAY")
    ptrCheckMark:SetWidth(14); ptrCheckMark:SetHeight(14)
    ptrCheckMark:SetPoint("CENTER", ptrCheck, "CENTER", 0, 0)
    ptrCheckMark:SetTexture(RM.ICON_PATH .. "icon_circle_S")
    ptrCheckMark:SetVertexColor(1, 0.1, 0.1, 0.9)
    ptrCheckMark:Hide()

    -- Label "Modo Puntero" debajo
    local ptrLabel = toolbar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    ptrLabel:SetPoint("TOP", ptrCheck, "BOTTOM", 0, -1)
    ptrLabel:SetText("Puntero / Alt")
    BigFont(ptrLabel, 8)
    ptrLabel:SetTextColor(0.7, 0.7, 0.7, 1)

    -- Boton rojo encima del checkbox (limpiar punteros en red, solo RL)
    local ptrClearBtn = CreateFrame("Button", nil, toolbar)
    ptrClearBtn:SetWidth(12); ptrClearBtn:SetHeight(12)
    ptrClearBtn:SetPoint("BOTTOM", ptrCheck, "TOP", 0, 2)
    ptrClearBtn:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 5, insets={left=1,right=1,top=1,bottom=1}
    })
    ptrClearBtn:SetBackdropColor(0.7, 0.05, 0.05, 1)
    ptrClearBtn:SetBackdropBorderColor(1, 0.2, 0.2, 1)
    ptrClearBtn:EnableMouse(true)
    ptrClearBtn:SetScript("OnClick", function()
        if not RM.Permissions.IsRL() then
            MF.ConsoleMsg("Solo el RL puede limpiar los punteros.", 1, 0.3, 0.3)
            return
        end
        for _, slot in ipairs(RM.state.pointerSlots) do
            slot.owner = nil; slot.lastX = nil; slot.lastY = nil
        end
        MF.UpdatePointerSlotUI()
        RM.Network.SendRaw("PTR_CLEAR")
        MF.ConsoleMsg("Punteros en red limpiados.", 0.4, 1, 0.4)
    end)
    ptrClearBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(ptrClearBtn, "ANCHOR_TOP")
        GameTooltip:SetText("Limpiar punteros en red")
        GameTooltip:AddLine("Solo disponible para el RL", 0.7,0.7,0.7,true)
        GameTooltip:Show()
    end)
    ptrClearBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    ptrCheck:SetScript("OnClick", function()
        if not RM.Permissions.CanPlace() then
            MF.ConsoleMsg("Sin permisos: no eres RL ni Asistente autorizado.", 1, 0.3, 0.2)
            return
        end

        if RM.state.pointerActive then
            -- Desactivar: limpiar slot localmente primero
            local prevSlot = RM.state.myPointerSlot
            if prevSlot then
                RM.state.pointerSlots[prevSlot].owner = nil  -- <-- FIX: liberar slot local
            end
            RM.state.pointerActive = false
            RM.state.myPointerSlot = nil
            ptrCheckMark:Hide()
            ptrCheck:SetBackdropBorderColor(0.5, 0.42, 0.22, 0.9)
            if localPointerFrame then localPointerFrame:Hide() end
            RM.Network.SendPointerRelease()
            MF.ConsoleMsg("Modo puntero desactivado.")
            MF.UpdatePointerSlotUI()
        else
            -- Activar: RL siempre fuerza slot 1, asistentes buscan del 2 al 4
            local foundSlot = nil
            local myName = UnitName("player")

            if RM.Permissions.IsRL() then
                -- RL siempre toma el slot 1 (rojo), sin importar el estado
                foundSlot = 1
                RM.state.pointerSlots[1].owner = nil  -- limpiar por si quedo sucio
            else
                -- Asistentes buscan slots 2, 3, 4 libres
                for i = 2, 4 do
                    if not RM.state.pointerSlots[i].owner then
                        foundSlot = i
                        break
                    end
                end
            end

            if not foundSlot then
                MF.ConsoleMsg("Todos los slots de puntero estan ocupados.", 1, 0.6, 0.1)
                return
            end

            RM.state.pointerActive = true
            RM.state.myPointerSlot = foundSlot
            local slot = RM.state.pointerSlots[foundSlot]
            slot.owner = myName
            ptrCheckMark:Show()
            ptrCheck:SetBackdropBorderColor(slot.r, slot.g, slot.b, 1)

            if localPointerFrame then
                localPointerFrame.tex:SetVertexColor(slot.r, slot.g, slot.b, 1.0)
            end

            RM.Network.SendPointerClaim(slot.color)
            MF.ConsoleMsg("Modo puntero activado (" .. slot.color .. ").")
            MF.UpdatePointerSlotUI()
        end
    end)
    ptrCheck:SetScript("OnEnter", function()
        GameTooltip:SetOwner(ptrCheck, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Activar/desactivar modo puntero")
        GameTooltip:Show()
    end)
    ptrCheck:SetScript("OnLeave", function() GameTooltip:Hide() end)
    ptrCheck:EnableMouse(true)
    xOff = xOff + 28

    -- Funcion publica para forzar desactivacion desde exterior (RAID_ROSTER_UPDATE, PTR_CLEAR, timeout)
    MF.SetPointerActive = function(active)
        if active then return end  -- solo se llama con false (forzar desactivacion)
        local prevSlot = RM.state.myPointerSlot
        if prevSlot then
            RM.state.pointerSlots[prevSlot].owner = nil
        end
        RM.state.pointerActive = false
        RM.state.myPointerSlot = nil
        ptrCheckMark:Hide()
        ptrCheck:SetBackdropBorderColor(0.5, 0.42, 0.22, 0.9)
        if localPointerFrame then localPointerFrame:Hide() end
        MF.ConsoleMsg("Puntero liberado.", 1, 0.7, 0.3)
        MF.UpdatePointerSlotUI()
    end

    -- 4 indicadores de slot de color
    MF.slotIndicators = {}
    local SLOT_SZ = 16
    for i, slot in ipairs(RM.state.pointerSlots) do
        local ind = CreateFrame("Frame", nil, toolbar)
        ind:SetWidth(SLOT_SZ); ind:SetHeight(SLOT_SZ)
        ind:SetPoint("LEFT", toolbar, "LEFT", xOff + (i-1)*(SLOT_SZ+3), 0)
        local ibg = ind:CreateTexture(nil, "BACKGROUND")
        ibg:SetAllPoints(ind)
        ibg:SetTexture(slot.r * 0.3, slot.g * 0.3, slot.b * 0.3, 0.95)
        local icircle = ind:CreateTexture(nil, "ARTWORK")
        icircle:SetWidth(10); icircle:SetHeight(10)
        icircle:SetPoint("CENTER", ind, "CENTER", 0, 0)
        icircle:SetTexture(RM.ICON_PATH .. "icon_circle_S")
        icircle:SetVertexColor(slot.r, slot.g, slot.b, 0.9)
        ind:SetAlpha(0.25)  -- vacio por defecto
        table.insert(MF.slotIndicators, ind)
    end
    xOff = xOff + 4*(SLOT_SZ+3) + 8

    -- Mini consola informativa (cuadro azul)
    -- Ancho dinamico: se extiende hasta justo antes del bloque de escenas (sceneBar)
    local consoleW = 160  -- ancho minimo de fallback
    local consoleFrame = CreateFrame("Frame", nil, toolbar)
    consoleFrame:SetHeight(TOOLBAR_H - 10)
    consoleFrame:SetPoint("LEFT", toolbar, "LEFT", xOff, 0)
    -- SetClipsChildren no disponible en vanilla 1.12
    consoleFrame:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets   = { left=3, right=3, top=3, bottom=3 },
    })
    consoleFrame:SetBackdropColor(0.04, 0.07, 0.15, 0.97)
    consoleFrame:SetBackdropBorderColor(0.2, 0.4, 0.9, 0.9)
    MF.consoleFrame = consoleFrame   -- exponer para el OnUpdate

    MF.consoleText = consoleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    MF.consoleText:SetPoint("TOPLEFT",     consoleFrame, "TOPLEFT",     5,  -5)
    MF.consoleText:SetPoint("BOTTOMRIGHT", consoleFrame, "BOTTOMRIGHT", -5,  5)
    MF.consoleText:SetJustifyH("LEFT")
    MF.consoleText:SetJustifyV("MIDDLE")
    BigFont(MF.consoleText, 9)
    MF.consoleText:SetText("RaidMark v" .. RM.VERSION)
    MF.consoleText:SetTextColor(0.4, 0.7, 1, 1)
    consoleCurrentMsg = { text = "RaidMark v" .. RM.VERSION, r = 0.4, g = 0.7, b = 1.0 }

    -- [Grid] -- cuadricula local con sliders de opacidad y densidad
    local gridActive = false
    local gridAlpha  = 0.3
    local gridCols   = 12
    local gridRows   = 8
    local gridLines  = {}

    -- Textura de fondo para C'thun exterior
    local gridBgTexture = nil
    local CTHEUN_GRID_MAP_KEY = "cthun_normal"
    local CTHUN_GRID_IMG_W = 1024
    local CTHUN_GRID_IMG_H = 512

    local function buildGrid()
        -- Limpiar líneas anteriores y fondo
        for _, l in ipairs(gridLines) do l:Hide() end
        gridLines = {}
        if gridBgTexture then
            gridBgTexture:Hide()
            gridBgTexture = nil
        end
        if not gridActive then return end

        -- Si es C'thun exterior, mostrar imagen de guía ENCIMA del mapa
        if RM.state.currentMap == CTHEUN_GRID_MAP_KEY then
            gridBgTexture = contentFrame:CreateTexture(nil, "OVERLAY")
            gridBgTexture:SetAllPoints(contentFrame)
            
            local texPath = "Interface\\AddOns\\RaidMark\\maps\\map_cthun_grid"
            gridBgTexture:SetTexture(texPath)
            
            -- Escalar imagen 1024x512 al lienzo 1365x768 sin distorsión
            local canvasW = 1365
            local canvasH = 768
            local scale = math.min(canvasW / CTHUN_GRID_IMG_W, canvasH / CTHUN_GRID_IMG_H)
            local newW = CTHUN_GRID_IMG_W * scale * 1.1
            local newH = CTHUN_GRID_IMG_H * scale * 1.1
            local u1 = (canvasW - newW) / canvasW / 2
            local v1 = (canvasH - newH) / canvasH / 2
            gridBgTexture:SetTexCoord(u1, 1-u1, v1, 1-v1)
            
            gridBgTexture:SetAlpha(gridAlpha)
            gridBgTexture:Show()
            return
        end


        -- Rejilla normal
        for i = 1, gridCols-1 do
            local l = contentFrame:CreateTexture(nil, "OVERLAY")
            l:SetWidth(1); l:SetHeight(MAP_H)
            l:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", MAP_W/gridCols*i, 0)
            l:SetTexture(1,1,1,gridAlpha)
            l:Show()
            table.insert(gridLines, l)
        end
        for i = 1, gridRows-1 do
            local l = contentFrame:CreateTexture(nil, "OVERLAY")
            l:SetWidth(MAP_W); l:SetHeight(1)
            l:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, -MAP_H/gridRows*i)
            l:SetTexture(1,1,1,gridAlpha)
            l:Show()
            table.insert(gridLines, l)
        end
    end

    local gridBtn = makeToolbarBtn("Grid", 72)
    gridBtn.labelText:SetTextColor(0.6, 0.8, 1, 1)
    gridBtn:SetPoint("RIGHT", toolbar, "RIGHT", -8, 0)
    MF.gridBtn = gridBtn

    -- Panel de sliders (oculto hasta activar Grid)
    local gridPanel = CreateFrame("Frame", "RaidMarkGridPanel", UIParent)
    gridPanel:SetWidth(220); gridPanel:SetHeight(48)
    gridPanel:SetFrameStrata("FULLSCREEN_DIALOG")
    gridPanel:SetFrameLevel(120)
    gridPanel:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8, insets={left=2,right=2,top=2,bottom=2}
    })
    gridPanel:SetBackdropColor(0.06, 0.06, 0.08, 0.95)
    gridPanel:SetBackdropBorderColor(0.4, 0.35, 0.2, 0.8)
    gridPanel:Hide()

    -- Label opacidad
    local lblAlpha = gridPanel:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    lblAlpha:SetPoint("BOTTOMLEFT", gridPanel, "BOTTOMLEFT", 6, 28)
    lblAlpha:SetText("Opac:")
    lblAlpha:SetTextColor(0.8,0.8,0.6,1)

    -- Slider opacidad
    local slAlpha = CreateFrame("Slider","RaidMarkGridAlpha",gridPanel,"OptionsSliderTemplate")
    slAlpha:SetWidth(140); slAlpha:SetHeight(14)
    slAlpha:SetPoint("BOTTOMLEFT", gridPanel, "BOTTOMLEFT", 52, 24)
    slAlpha:SetMinMaxValues(0.05, 0.9)
    slAlpha:SetValue(0.3)
    slAlpha:SetValueStep(0.05)
    getglobal(slAlpha:GetName().."Low"):SetText("")
    getglobal(slAlpha:GetName().."High"):SetText("")
    getglobal(slAlpha:GetName().."Text"):SetText("")
    slAlpha:SetScript("OnValueChanged", function()
        gridAlpha = slAlpha:GetValue()
        for _, l in ipairs(gridLines) do l:SetTexture(1,1,1,gridAlpha) end
        if gridBgTexture then
            gridBgTexture:SetAlpha(gridAlpha)
        end
    end)

    -- Label densidad
    local lblDens = gridPanel:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    lblDens:SetPoint("BOTTOMLEFT", gridPanel, "BOTTOMLEFT", 6, 6)
    lblDens:SetText("Grid:")
    lblDens:SetTextColor(0.8,0.8,0.6,1)

    -- Slider densidad (4..32 columnas/filas)
    local slDens = CreateFrame("Slider","RaidMarkGridDens",gridPanel,"OptionsSliderTemplate")
    slDens:SetWidth(140); slDens:SetHeight(14)
    slDens:SetPoint("BOTTOMLEFT", gridPanel, "BOTTOMLEFT", 52, 2)
    slDens:SetMinMaxValues(4, 32)
    slDens:SetValue(12)
    slDens:SetValueStep(2)
    getglobal(slDens:GetName().."Low"):SetText("")
    getglobal(slDens:GetName().."High"):SetText("")
    getglobal(slDens:GetName().."Text"):SetText("")
    slDens:SetScript("OnValueChanged", function()
        local v = math.floor(slDens:GetValue()/2+0.5)*2
        gridCols = v
        gridRows = math.floor(v * MAP_H / MAP_W + 0.5)
        if gridRows < 1 then gridRows = 1 end
        buildGrid()
    end)

    gridBtn:SetScript("OnClick", function()
        gridActive = not gridActive
        if gridActive then
            gridBtn.labelText:SetTextColor(1, 1, 0.3, 1)
            gridBtn:SetBackdropBorderColor(0.8, 0.8, 0.2, 1)
            gridPanel:ClearAllPoints()
            gridPanel:SetPoint("BOTTOMRIGHT", gridBtn, "TOPRIGHT", 0, 4)
            gridPanel:Show()
        else
            gridBtn.labelText:SetTextColor(0.6, 0.8, 1, 1)
            gridBtn:SetBackdropBorderColor(0.5, 0.42, 0.22, 0.9)
            gridPanel:Hide()
        end
        buildGrid()
    end)
    gridBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(gridBtn, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Mostrar/ocultar cuadricula (solo local)")
        GameTooltip:Show()
    end)
    gridBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- [Assist ON/OFF] -- visible para TODOS, accion solo para RL
    MF.assistBtn = makeToolbarBtn("Assist: OFF", 120)
    MF.assistBtn:SetPoint("RIGHT", gridBtn, "LEFT", -8, 0)

    -- Botón M Offline (a la derecha del assistBtn)
    local mOfflineBtn = makeToolbarBtn("M Offline", 80)
    mOfflineBtn:SetPoint("RIGHT", MF.assistBtn, "LEFT", -6, 0)
    mOfflineBtn.labelText:SetTextColor(1, 0.2, 0.2, 1)
    mOfflineBtn:SetBackdropBorderColor(0.7, 0.1, 0.1, 1)
    mOfflineBtn:SetScript("OnClick", function() MF.ToggleOfflineMode() end)
    mOfflineBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(mOfflineBtn,"ANCHOR_BOTTOM")
        if RM.state.offlineMode then
            GameTooltip:SetText("Salir del Modo Offline")
            GameTooltip:AddLine("Limpia el lienzo y restaura network", 0.7,0.7,0.7,true)
        else
            GameTooltip:SetText("Entrar en Modo Offline")
            GameTooltip:AddLine("Diseña estrategias sin conexion", 0.7,0.7,0.7,true)
            GameTooltip:AddLine("ADVERTENCIA: limpia el lienzo", 1,0.5,0.2,true)
        end
        GameTooltip:Show()
    end)
    mOfflineBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    MF.mOfflineBtn = mOfflineBtn

    -- Botón Sync P (sincronizar posicionamiento) - debajo de M Offline
    local syncPBtn = makeToolbarBtn("Sync P", 80)
    syncPBtn:SetPoint("RIGHT", mOfflineBtn, "LEFT", -6, 0)
    syncPBtn.labelText:SetTextColor(0.4, 1, 0.6, 1)
    syncPBtn:SetBackdropBorderColor(0.2, 0.7, 0.3, 1)
    syncPBtn:SetScript("OnClick", function()
        if not RM.Permissions.IsRL() then return end
        if RM.state.offlineMode then
            MF.ConsoleOffline("Estas en modo offline! Network deshabilitado.")
            return
        end
        -- SyncPositioning lee el slot seleccionado (rojo) directamente
        -- Si no hay slot seleccionado, SyncPositioning muestra el mensaje
        RM.Scenes.SyncPositioning()
        -- El slot permanece seleccionado para poder repetir Sync P facilmente
    end)
    syncPBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(syncPBtn, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Sync Posicionamiento")
        GameTooltip:AddLine("Coloca raiders segun mapa de posicion cargado", 0.7,0.7,0.7,true)
        GameTooltip:AddLine("Solo funciona si cargaste un slot verde (posi)", 0.4,1,0.4,true)
        GameTooltip:Show()
    end)
    syncPBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    MF.syncPBtn = syncPBtn

    -- ── Sistema de Fases/Escenas (anclado a la izquierda de assistBtn) ──
    if RM.Scenes then
        RM.Scenes.Init()
        RM.Scenes.BuildUI(toolbar, MF.syncPBtn, makeToolbarBtn)
        -- Ajustar el ancho del consoleFrame para llegar hasta el sceneBar
        local sb = getglobal("RaidMarkSceneBar")
        if sb then
            consoleFrame:SetPoint("RIGHT", sb, "LEFT", -8, 0)
        else
            consoleFrame:SetWidth(consoleW)
        end
    end
    MF.assistBtn:SetScript("OnClick", function()
        if RM.Permissions.IsRL() then
            RM.state.assistCanMove = not RM.state.assistCanMove
            RM.Network.SendPermissions(RM.state.assistCanMove)
            MF.UpdateAssistBtn()
        else
            UIErrorsFrame:AddMessage("No tienes permisos. No eres RL ni Asistente.", 1, 0.3, 0.3, 1, 3)
        end
    end)
    MF.assistBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(MF.assistBtn, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Permitir a los Asistentes mover iconos")
        GameTooltip:Show()
    end)
    MF.assistBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    MF.UpdateAssistBtn()
end

function MF.UpdateAssistBtn()
    if not MF.assistBtn then return end
    MF.assistBtn:Show()
    if RM.state.assistCanMove then
        MF.assistBtn.labelText:SetText("Assist: ON")
        MF.assistBtn.labelText:SetTextColor(0.2, 1, 0.2, 1)
        MF.assistBtn:SetBackdropBorderColor(0.2, 0.6, 0.2, 1)
    else
        MF.assistBtn.labelText:SetText("Assist: OFF")
        MF.assistBtn.labelText:SetTextColor(0.6, 0.6, 0.6, 1)
        MF.assistBtn:SetBackdropBorderColor(0.5, 0.42, 0.22, 0.9)
    end
    -- Actualizar botones de rol segun permisos
    if MF.UpdateEnviarRolesBtn then MF.UpdateEnviarRolesBtn() end
    if MF.UpdateSyncRolBtn     then MF.UpdateSyncRolBtn()     end
end


-- Crear el botón de Escala en la Toolbar
MF.scaleBtn = CreateFrame("Button", nil, mainFrame)
MF.scaleBtn:SetWidth(80)
MF.scaleBtn:SetHeight(24)
-- Ajusta el SetPoint según dónde estén tus otros botones (ej. al lado del botón de Assist)
MF.scaleBtn:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -120, -12) 
MF.scaleBtn:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
MF.scaleBtn:SetBackdropColor(0.1, 0.1, 0.1, 0.9)

MF.scaleBtn.labelText = MF.scaleBtn:CreateFontString(nil, "OVERLAY")
BigFont(MF.scaleBtn.labelText, 12)
MF.scaleBtn.labelText:SetPoint("CENTER", 0, 0)
MF.scaleBtn.labelText:SetText("Scale: 100%")
MF.scaleBtn.labelText:SetTextColor(1, 0.8, 0, 1)

MF.scaleBtn:SetScript("OnClick", function()
    -- Lógica cíclica: 1.0 -> 0.9 -> 0.8 -> 1.0
    if RM.state.currentScale == 1.0 then
        RM.state.currentScale = 0.9
        MF.scaleBtn.labelText:SetText("Scale: 90%")
    elseif RM.state.currentScale == 0.9 then
        RM.state.currentScale = 0.8
        MF.scaleBtn.labelText:SetText("Scale: 80%")
    else
        RM.state.currentScale = 1.0
        MF.scaleBtn.labelText:SetText("Scale: 100%")
    end
    
    -- Aplicar la escala a todo el marco principal
    mainFrame:SetScale(RM.state.currentScale)
    -- Persistir escala
    if RaidMarkDB then RaidMarkDB.savedScale = RM.state.currentScale end
end)



-- -- Cargar textura del mapa --------------------------------------
function MF.LoadMap(mapKey)
    local mapDef = RaidMark_Maps[mapKey]
    if not mapDef then return end

    mapTexture:SetTexture(nil)
    mapTexture:SetTexture(mapDef.file)
    mapTexture:SetTexCoord(0, mapDef.u2, 0, mapDef.v2)
    mapTexture:SetAllPoints(contentFrame)
    titleText:SetText("RaidMark -- " .. mapDef.label)
    titleText:SetTextColor(0.4, 0.8, 1, 1)
    RM.Icons.RedrawAll()
end

-- -- Mostrar / Ocultar / Toggle -----------------------------------
function MF.Show()
    mainFrame:Show()
    RM.state.mapVisible = true
    -- Restaurar escala y posicion guardadas
    if RaidMarkDB then
        if RaidMarkDB.savedScale then
            RM.state.currentScale = RaidMarkDB.savedScale
            mainFrame:SetScale(RM.state.currentScale)
            local pct = math.floor(RM.state.currentScale * 100 + 0.5)
            if MF.scaleBtn then
                MF.scaleBtn.labelText:SetText("Scale: "..pct.."%")
            end
        end
        if RaidMarkDB.savedX and RaidMarkDB.savedY then
            mainFrame:ClearAllPoints()
            mainFrame:SetPoint(
                RaidMarkDB.savedPoint or "CENTER",
                UIParent,
                RaidMarkDB.savedPoint or "CENTER",
                RaidMarkDB.savedX,
                RaidMarkDB.savedY)
        end
    end
    if RM.state.currentMap then
        MF.LoadMap(RM.state.currentMap)
    end
    MF.RebuildRosterButtons()
    MF.UpdateAssistBtn()
end

function MF.SetAssignCooldown(seconds)
    assignCooldown = seconds or 10
end

function MF.Hide()
    mainFrame:Hide()
    RM.state.mapVisible = false
    -- Cerrar paneles flotantes que son hijos de UIParent
    if RaidMarkGridPanel then RaidMarkGridPanel:Hide() end
    if RaidMarkArrowDD then RaidMarkArrowDD:Hide() end
    if RaidMarkGrandSlotDD then RaidMarkGrandSlotDD:Hide() end
    if RaidMarkFilterDD then RaidMarkFilterDD:Hide() end
    if RaidMarkHelp then RaidMarkHelp:Hide() end
    -- Cerrar panel de consumibles y sus dropdowns flotantes
    if RaidMarkCSPanel then RaidMarkCSPanel:Hide() end
    if RaidMarkCSResistDD then RaidMarkCSResistDD:Hide() end
    if RaidMarkActiveWeightPopup then
        RaidMarkActiveWeightPopup:Hide()
        RaidMarkActiveWeightPopup = nil
    end
end


-- -- LÓGICA DE SLOTS Y MATCHMAKING -------------------------------

function MF.SelectSlot(id)
    RM.state.selectedSlot = id
    for i, btn in ipairs(MF.slotBtns) do
        if i == id then btn:LockHighlight() else btn:UnlockHighlight() end
    end
    
    if RaidMarkDB.slots[id] then
        if RaidMarkDB.slots[id].isTemplate then
            MF.autoBtn:Enable()
            MF.statusTxt:SetText("|cff00ccffCONF DE POSICION|r")
        else
            MF.autoBtn:Disable()
            MF.statusTxt:SetText("|cff00ff00CONF DE PLAYERS|r")
        end
    else
        MF.autoBtn:Disable()
        MF.statusTxt:SetText("|cff999999SLOT " .. id .. " VACÍO|r")
    end
end

function MF.SaveToSlot()
    local id = RM.state.selectedSlot
    if not id then return end

    RaidMarkDB.slots[id] = {
        isTemplate = RM.state.editMode,
        icons = {}
    }

    for iconId, data in pairs(RM.state.placedIcons) do
        table.insert(RaidMarkDB.slots[id].icons, {
            type = data.iconType, x = data.x, y = data.y, label = data.label
        })
    end

    if MF.ConsoleMsg then MF.ConsoleMsg("Slot "..id.." guardado.", 0.4,1,0.6) end
    if RM.state.editMode then MF.ToggleEditMode() end
end

function MF.ToggleEditMode()
    RM.state.editMode = not RM.state.editMode
    if RM.state.editMode then
        MF.statusTxt:SetText("|cffff0000OFFLINE MODO EDIT|r")
        MF.editBtn:LockHighlight()
        RM.ClearAll()
    else
        MF.statusTxt:SetText("|cff00ff00MODO: ONLINE|r")
        MF.editBtn:UnlockHighlight()
        RM.ClearAll()
        MF.RebuildRosterButtons()
    end
end

function MF.RunAutoSlot()
    local id = RM.state.selectedSlot
    if not RaidMarkDB.slots[id] or not RaidMarkDB.slots[id].isTemplate then return end
    
    RM.ClearAll()
    local saved = RaidMarkDB.slots[id].icons
    local classPriority = {
        ["TANK"]   = {"WARRIOR", "DRUID", "PALADIN"},
        ["HEALER"] = {"PRIEST", "SHAMAN", "PALADIN", "DRUID"},
        ["DPS"]    = {"ROGUE", "MAGE", "WARLOCK", "HUNTER", "WARRIOR"}
    }
    
    local available = {}
    for i = 1, GetNumRaidMembers() do
        local name, _, _, _, class = GetRaidRosterInfo(i)
        table.insert(available, { name = name, class = class, used = false })
    end

    local function findCandidate(iconType)
        local role = (iconType == "TANK" or iconType == "HEALER") and iconType or "DPS"
        for _, class in ipairs(classPriority[role]) do
            for _, p in ipairs(available) do
                if not p.used and p.class == class then
                    p.used = true; return p.name
                end
            end
        end
        return nil
    end

    for _, icon in ipairs(saved) do
        local bestName = findCandidate(icon.type)
        if bestName then RM.Icons.PlaceNew(icon.type, icon.x, icon.y, bestName) end
    end
end


function MF.Toggle()
    if mainFrame:IsVisible() then
        MF.Hide()
    else
        MF.Show()
    end
end

-- -- Construir UI -- llamado desde core.lua en ADDON_LOADED --------
-- ── Sistema de Modo Offline ──────────────────────────────────────
RM.state.offlineMode      = false
local offlineWarningShown = false


-- Funcion de consola (box informativo)
function MF.ConsoleOffline(msg, r, g, b)
    if MF.ConsoleMsg then MF.ConsoleMsg(msg, r or 1, g or 0.2, b or 0.2) end
end

function MF.ToggleOfflineMode()
    if not RM.state.offlineMode then
        -- Primer click: advertencia
        if not offlineWarningShown then
            offlineWarningShown = true
            MF.ConsoleOffline("ADVERTENCIA: entrar en Modo Offline limpiara el lienzo. Click de nuevo para confirmar.", 1,0.6,0.1)
            return
        end
        -- Segundo click: entrar
        offlineWarningShown = false
        RM.state.offlineMode = true

        -- Limpiar lienzo (sin broadcast si es RL)
        RM.ClearAll()
        if RM.Permissions.IsRL() then RM.Network.SendClear() end

        -- Desactivar Assist automaticamente al entrar offline
        if RM.state.assistCanMove then
            RM.state._assistBeforeOffline = true  -- recordar que estaba ON
            RM.state.assistCanMove = false
            MF.UpdateAssistBtn()
        else
            RM.state._assistBeforeOffline = false
        end

        -- Actualizar UI
        MF.ConsoleOffline("Modo Offline activado. Network deshabilitado.", 1,0.2,0.2)
        if MF.mOfflineBtn then
            MF.mOfflineBtn.labelText:SetText("Salir Offline")
            MF.mOfflineBtn:SetBackdropBorderColor(1, 0.8, 0, 1)
            MF.mOfflineBtn.labelText:SetTextColor(1, 0.8, 0, 1)
        end
        -- Mensaje persistente
        local function persistMsg()
            if RM.state.offlineMode then
                MF.ConsoleOffline("[ MODO OFFLINE ]", 1, 0.15, 0.15)
            end
        end
        local persistFrame = CreateFrame("Frame","RaidMarkOfflinePersist")
        persistFrame:SetScript("OnUpdate", function()
            if not RM.state.offlineMode then
                persistFrame:SetScript("OnUpdate",nil); return
            end
        end)
        -- Mostrar cada 8s
        local pt = 0
        persistFrame:SetScript("OnUpdate", function()
            pt = pt + arg1
            if pt >= 8 then pt=0; persistMsg() end
        end)

        MF.RebuildRosterButtons()  -- muestra iconos de rol offline

    else
        -- Salir del modo offline
        RM.state.offlineMode = false
        offlineWarningShown  = false
        RM.ClearAll()
        -- Restaurar Assist si estaba ON antes de entrar offline
        if RM.state._assistBeforeOffline then
            RM.state.assistCanMove = true
            RM.state._assistBeforeOffline = false
            MF.UpdateAssistBtn()
            if RM.Permissions.IsRL() then
                RM.Network.SendPermissions(true)
            end
        end
        MF.ConsoleOffline("Modo Offline desactivado.", 0.4, 1, 0.4)
        if MF.mOfflineBtn then
            MF.mOfflineBtn.labelText:SetText("M Offline")
            MF.mOfflineBtn:SetBackdropBorderColor(0.7, 0.1, 0.1, 1)
            MF.mOfflineBtn.labelText:SetTextColor(1, 0.2, 0.2, 1)
        end
        MF.RebuildRosterButtons()
    end
end

-- Guard global de network en modo offline
local _origSendRaw
function RM.Network.IsOffline() return RM.state.offlineMode == true end

-- Registrar CHAT_MSG_RAID para auto-asignacion
local raidChatFrame = CreateFrame("Frame","RaidMarkRaidChat")
raidChatFrame:RegisterEvent("CHAT_MSG_RAID")
raidChatFrame:SetScript("OnEvent", function()
    if MF.OnRaidChat then MF.OnRaidChat(arg1, arg2) end
end)

-- Exponer auto-total para acceso desde widget
function MF.RunAutoTotal()
    if autoTotalBtn then
        autoTotalBtn:GetScript("OnClick")(autoTotalBtn)
    end
end

function MF.Build()
    buildRoleButtons()
    buildToolbar()
    buildPointerLocalFrame()
    -- Panel de consumibles (consumables.lua)
    if RM.Consumables and RM.Consumables.Build then
        RM.Consumables.Build(mainFrame, sidePanel)
    end
    MF.ConsoleMsg("RaidMark v" .. RM.VERSION .. " listo.")
end
