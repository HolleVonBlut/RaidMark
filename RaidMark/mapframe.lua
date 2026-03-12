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
DEFAULT_CHAT_FRAME:AddMessage("RaidMark DEBUG: mapframe.lua inicio OK")

-- -- Dimensiones (+50%) --------------------------------------------
local MAP_W         = 1050  -- era 700
local MAP_H         = 591   -- era 394
local TOOLBAR_H     = 48    -- era 36
local PANEL_W       = 240   -- era 160
local TOTAL_W       = MAP_W + PANEL_W
local TOTAL_H       = MAP_H + TOOLBAR_H + 30  -- +30 titlebar

-- -- Crear el frame principal -------------------------------------
local mainFrame = CreateFrame("Frame", "RaidMarkMainFrame", UIParent)
mainFrame:SetWidth(TOTAL_W)
mainFrame:SetHeight(TOTAL_H)
mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
mainFrame:SetFrameStrata("HIGH")
mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", function() mainFrame:StartMoving() end)
mainFrame:SetScript("OnDragStop",  function() mainFrame:StopMovingOrSizing() end)
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
    if arg1 ~= "LeftButton" then return end
    if not RM.Permissions.CanPlace() then return end
    if not MF.selectedIconType then return end

    local mLeft = contentFrame:GetLeft()
    local mTop  = contentFrame:GetTop()
    local mW    = contentFrame:GetWidth()
    local mH    = contentFrame:GetHeight()
    local cx, cy = GetCursorPosition()

    -- Escala de UI
    local scale = UIParent:GetScale()
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
local ROLE_BUTTONS = {
    { type="TANK",      label="Tank",      x=8,   y=-8  },
    { type="HEALER",    label="Healer",    x=62,  y=-8  },
    { type="DPS",       label="DPS",       x=116, y=-8  },
    { type="DPS_MELEE", label="Melee",     x=170, y=-8  },
    { type="CASTER",    label="Caster",    x=8,   y=-62 },
    { type="ARROW",     label="Flecha",    x=62,  y=-62 },
}

local CIRCLE_BUTTONS = {
    { type="CIRCLE_S",  label="S",   x=8,   y=-122 },
    { type="CIRCLE_M",  label="M",   x=62,  y=-122 },
    { type="CIRCLE_L",  label="L",   x=116, y=-122 },
    { type="CIRCLE_XL", label="XL",  x=170, y=-122 },
}

MF.selectedIconType   = nil
MF.selectedMemberName = nil
MF.allButtons         = {}

local function buildRoleButtons()
    local lbl = sidePanel:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    lbl:SetPoint("TOPLEFT", sidePanel, "TOPLEFT", 8, -4)
    lbl:SetText("Iconos de Rol")
    lbl:SetTextColor(0.8, 0.67, 0.27, 1)

    for _, def in ipairs(ROLE_BUTTONS) do
        local btn = makeIconButton(
            sidePanel, def.type,
            RM.ICON_TEXTURE[def.type],
            46,  -- era 36, +50%
            def.x, def.y, def.label
        )
        table.insert(MF.allButtons, btn)
    end

    local lbl2 = sidePanel:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    lbl2:SetPoint("TOPLEFT", sidePanel, "TOPLEFT", 8, -114)
    lbl2:SetText("Areas")
    lbl2:SetTextColor(0.8, 0.67, 0.27, 1)

    for _, def in ipairs(CIRCLE_BUTTONS) do
        local btn = makeIconButton(
            sidePanel, def.type,
            RM.ICON_TEXTURE[def.type],
            42,  -- era 28, +50%
            def.x, def.y, def.label
        )
        table.insert(MF.allButtons, btn)
    end
end

-- -- Panel de miembros del raid (scrollable) ----------------------
local MEMBER_PANEL_Y    = -175   -- ajustado para mayor panel
local MEMBER_BTN_H      = 22     -- era 20
local MEMBER_BTN_W      = PANEL_W - 16
local MAX_VISIBLE       = 20     -- mas miembros visibles en panel mas grande

local memberScrollFrame = CreateFrame("ScrollFrame", "RaidMarkMemberScroll", sidePanel)
memberScrollFrame:SetWidth(PANEL_W - 8)
memberScrollFrame:SetHeight(MAX_VISIBLE * (MEMBER_BTN_H + 2))
memberScrollFrame:SetPoint("TOPLEFT", sidePanel, "TOPLEFT", 4, MEMBER_PANEL_Y)

local memberContent = CreateFrame("Frame", "RaidMarkMemberContent", memberScrollFrame)
memberContent:SetWidth(PANEL_W - 8)
memberContent:SetHeight(1)  -- se ajusta dinamicamente
memberScrollFrame:SetScrollChild(memberContent)

-- Divider
local divider = sidePanel:CreateTexture(nil, "ARTWORK")
divider:SetWidth(PANEL_W - 16)
divider:SetHeight(1)
divider:SetPoint("TOPLEFT", sidePanel, "TOPLEFT", 8, MEMBER_PANEL_Y - 4)
divider:SetTexture(0.4, 0.35, 0.2, 0.6)

local memberLabel = sidePanel:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
memberLabel:SetPoint("TOPLEFT", sidePanel, "TOPLEFT", 8, MEMBER_PANEL_Y - 10)
memberLabel:SetText("Miembros del Raid")
 memberLabel:SetTextColor(0.8, 0.67, 0.27, 1)

-- Botones de miembros (se reconstruyen con el roster)
local memberButtons = {}

function MF.RebuildRosterButtons()
    -- Limpiar botones previos
    for _, btn in ipairs(memberButtons) do
        btn:Hide()
    end
    memberButtons = {}

    local members = RM.Roster.GetSortedList()
    local totalH  = 0

    for i, data in ipairs(members) do
        local yOff = -(i-1) * (MEMBER_BTN_H + 2)

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

        table.insert(memberButtons, btn)
        totalH = totalH + MEMBER_BTN_H + 2
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
    fs:SetPoint("CENTER", btn, "CENTER", 0, 0)
    fs:SetText(label)
    btn.labelText = fs
    btn:EnableMouse(true)
    return btn
end

-- -- Dropdown frame -----------------------------------------------
local dropdownFrame = CreateFrame("Frame", "RaidMarkDropdown", UIParent)
dropdownFrame:SetWidth(160)
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

local dropItems = {}

local function closeDropdown()
    dropdownFrame:Hide()
    for _, item in ipairs(dropItems) do item:Hide() end
    dropItems = {}
end

local function openDropdown(anchorBtn)
    if dropdownFrame:IsVisible() then closeDropdown() return end
    for _, item in ipairs(dropItems) do item:Hide() end
    dropItems = {}

    -- Guard: RaidMark_Maps puede no estar cargado aun
    if not RaidMark_Maps then
        DEFAULT_CHAT_FRAME:AddMessage("RaidMark: maps.lua no cargado.")
        return
    end

    local entries = {}
    for key, def in pairs(RaidMark_Maps) do
        table.insert(entries, { key=key, label=def.label })
    end
    table.sort(entries, function(a,b) return a.label < b.label end)

    local ITEM_H = 22
    dropdownFrame:SetHeight(table.getn(entries) * ITEM_H + 8)

    for i, entry in ipairs(entries) do
        local item = CreateFrame("Button", nil, dropdownFrame)
        item:SetWidth(154)
        item:SetHeight(ITEM_H)
        item:SetPoint("TOPLEFT", dropdownFrame, "TOPLEFT", 3, -(4 + (i-1)*ITEM_H))
        item:SetFrameLevel(dropdownFrame:GetFrameLevel() + 1)
        item:EnableMouse(true)

        if i > 1 then
            local sep = item:CreateTexture(nil, "ARTWORK")
            sep:SetWidth(148); sep:SetHeight(1)
            sep:SetPoint("TOPLEFT", item, "TOPLEFT", 0, 0)
            sep:SetTexture(0.4, 0.35, 0.2, 0.4)
        end

        local hl = item:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints(item)
        hl:SetTexture(0.4, 0.35, 0.15, 0.5)

        local fs = item:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("LEFT", item, "LEFT", 10, 0)
        fs:SetText(entry.label)
        fs:SetTextColor(0.9, 0.85, 0.6, 1)

        -- Captura local para evitar bug de closure en Lua 5.0
        local eKey   = entry.key
        local eLabel = entry.label
        item:SetScript("OnClick", function()
            if RM.Permissions.CanPlace() then
                RM.SetMap(eKey)
                RM.Network.SendMapChange(eKey)
                MF.encounterBtn.labelText:SetText("v  " .. eLabel)
            end
            closeDropdown()
        end)
        item:Show()
        table.insert(dropItems, item)
    end

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
ddOverlay:SetScript("OnMouseDown", function() closeDropdown() ddOverlay:Hide() end)
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
        else
            DEFAULT_CHAT_FRAME:AddMessage("RaidMark: Sin permisos.")
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
    syncBtn:SetPoint("LEFT", toolbar, "LEFT", xOff, 0)
    syncBtn:SetScript("OnClick", function()
        RM.Network.SendSyncRequest()
    end)
    syncBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(syncBtn, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Pedir al RL el estado actual del mapa")
        GameTooltip:Show()
    end)
    syncBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- [X Cerrar] -- anclado a la derecha
    local closeMenuBtn = makeToolbarBtn("X Cerrar", 100)
    closeMenuBtn.labelText:SetTextColor(1, 0.3, 0.3, 1)
    closeMenuBtn:SetPoint("RIGHT", toolbar, "RIGHT", -8, 0)
    closeMenuBtn:SetScript("OnClick", function() MF.Hide() end)
    closeMenuBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(closeMenuBtn, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Cerrar el mapa tactico")
        GameTooltip:Show()
    end)
    closeMenuBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- [Assist ON/OFF] -- a la izquierda del cerrar, solo para RL
    MF.assistBtn = makeToolbarBtn("Assist: OFF", 120)
    MF.assistBtn:SetPoint("RIGHT", closeMenuBtn, "LEFT", -8, 0)
    MF.assistBtn:SetScript("OnClick", function()
        if RM.Permissions.IsRL() then
            RM.state.assistCanMove = not RM.state.assistCanMove
            RM.Network.SendPermissions(RM.state.assistCanMove)
            MF.UpdateAssistBtn()
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
    if RM.Permissions.IsRL() then
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
    else
        MF.assistBtn:Hide()
    end
end

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
    if RM.state.currentMap then
        MF.LoadMap(RM.state.currentMap)
    end
    MF.RebuildRosterButtons()
    MF.UpdateAssistBtn()
end

function MF.Hide()
    mainFrame:Hide()
    RM.state.mapVisible = false
end

function MF.Toggle()
    if mainFrame:IsVisible() then
        MF.Hide()
    else
        MF.Show()
    end
end

-- -- Construir UI -- llamado desde core.lua en ADDON_LOADED --------
function MF.Build()
    buildRoleButtons()
    buildToolbar()
end
