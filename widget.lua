-- ============================================================
--  RaidMark -- widget.lua v1.6c
--  /rm w  o  boton "Widget" en el panel de consumibles
-- ============================================================
local RM = RaidMark
RM.Widget = {}
local WG = RM.Widget

WG.visible    = false
WG.locked     = true
WG.pullActive = false
local wFrame  = nil

-- ── Helpers de botones ────────────────────────────────────────────
local function makeWBtn(lbl, w, h, parent)
    local b = CreateFrame("Button", nil, parent or wFrame)
    b:SetWidth(w); b:SetHeight(h or 20)
    b:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize=5, insets={left=2,right=2,top=2,bottom=2}})
    b:SetBackdropColor(0.08,0.07,0.04,0.92)
    b:SetBackdropBorderColor(0.45,0.38,0.18,1)
    local fs = b:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    fs:SetAllPoints(b); fs:SetText(lbl)
    fs:SetFont("Fonts\\FRIZQT__.TTF",9,"")
    fs:SetTextColor(0.85,0.75,0.4,1)
    b.labelText = fs
    b._br=0.45; b._bg=0.38; b._bb=0.18
    b:SetScript("OnEnter",function() b:SetBackdropBorderColor(0.75,0.65,0.3,1) end)
    b:SetScript("OnLeave",function() b:SetBackdropBorderColor(b._br,b._bg,b._bb,1) end)
    return b
end

local function setBorder(b,r,g,bl)
    b._br=r; b._bg=g; b._bb=bl
    b:SetBackdropBorderColor(r,g,bl,1)
end

-- ── Estado Pull ───────────────────────────────────────────────────
local pullBtnRef = nil

local function applyPullState(active)
    WG.pullActive = active
    if not pullBtnRef then return end
    if active then
        pullBtnRef.labelText:SetText("Cancelar Pull")
        pullBtnRef.labelText:SetTextColor(1,1,1,1)
        pullBtnRef:SetBackdropColor(0.28,0.03,0.03,0.95)
        setBorder(pullBtnRef,0.9,0.1,0.1)
    else
        pullBtnRef.labelText:SetText("Pull")
        pullBtnRef.labelText:SetTextColor(0.5,0.8,1,1)
        pullBtnRef:SetBackdropColor(0.03,0.07,0.18,0.95)
        setBorder(pullBtnRef,0.15,0.4,0.75)
    end
end

-- Detectar /pull cancel de cualquier jugador via CHAT_MSG_SYSTEM
local pullSysFrame = CreateFrame("Frame","RaidMarkWidgetPullSys")
pullSysFrame:RegisterEvent("CHAT_MSG_SYSTEM")
pullSysFrame:RegisterEvent("RAID_BOSS_EMOTE")     -- "Pull in XX sec" emote
pullSysFrame:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
pullSysFrame:SetScript("OnEvent",function()
    local msg = string.lower(arg1 or "")
    local ev  = event
    if ev == "CHAT_MSG_SYSTEM" or ev == "RAID_BOSS_EMOTE" or
       ev == "CHAT_MSG_RAID_BOSS_EMOTE" then
        -- Pull abortado/cancelado
        if string.find(msg,"pull aborted") or
           string.find(msg,"pull.*cancel") or
           (string.find(msg,"pull") and string.find(msg,"cancel")) then
            applyPullState(false)
        end
        -- "already running a ready check" -> mostrar en widget
        if string.find(msg,"already") and string.find(msg,"ready check") then
            WG.setInfo("RC ya en marcha!", 6)
        end
    end
end)

-- ── InfoBox ───────────────────────────────────────────────────────
local wInfoClear    = nil
local wPendingMsg   = nil   -- mensaje pendiente si el widget no esta construido
local wPendingDur   = nil
local wPendingColor = nil   -- {r,g,b}

function WG.setInfo(txt, dur, r, g, b)
    -- Guardar siempre el mensaje pendiente por si el widget se abre despues
    wPendingMsg   = txt
    wPendingDur   = dur or 8
    wPendingColor = {r or 0.75, g or 0.92, b or 0.55}

    -- Si el widget no esta construido o visible, auto-mostrar
    if not WG.infoLbl then
        WG.Show()   -- construye y muestra el widget
    end

    if not WG.infoLbl then return end  -- fallback si Show fallo

    WG.infoLbl:SetText(txt or "")
    WG.infoLbl:SetTextColor(wPendingColor[1], wPendingColor[2], wPendingColor[3], 1)

    if wInfoClear then wInfoClear:SetScript("OnUpdate",nil) end
    wInfoClear = CreateFrame("Frame")  -- anonymous frame, no name conflict
    local t = 0
    local d = wPendingDur
    wInfoClear:SetScript("OnUpdate",function()
        t = t + arg1
        if t >= d then
            if WG.infoLbl then
                WG.infoLbl:SetText("")
                WG.infoLbl:SetTextColor(0.38,0.48,0.38,0.75)
            end
            wInfoClear:SetScript("OnUpdate",nil)
        end
    end)
end

-- Llamado internamente al mostrar el widget: aplica mensaje pendiente si existe
local function applyPendingMsg()
    if wPendingMsg and WG.infoLbl then
        WG.infoLbl:SetText(wPendingMsg)
        WG.infoLbl:SetTextColor(
            wPendingColor and wPendingColor[1] or 0.75,
            wPendingColor and wPendingColor[2] or 0.92,
            wPendingColor and wPendingColor[3] or 0.55, 1)
    end
end

-- ── Resist RW double-click system ────────────────────────────────
local resistArmed      = false
local resistArmedTimer = 0
local resistArmedFrame = nil
local activeResistIdx  = nil   -- indice en CS.RESIST_DEFS
local resistBtnRef     = nil

local function resetResistArmed()
    resistArmed      = false
    resistArmedTimer = 0
    if resistBtnRef then
        local rd = nil
        if activeResistIdx and RM.Consumables and RM.Consumables.GetResistDefs then
            rd = RM.Consumables.GetResistDefs()
        end
        if rd and activeResistIdx then
            local def = rd[activeResistIdx]
            resistBtnRef.labelText:SetText("Res:"..def.label)
            resistBtnRef.labelText:SetTextColor(def.r,def.g,def.b,1)
            setBorder(resistBtnRef,def.r*0.7,def.g*0.7,def.b*0.7)
        end
    end
end

-- ── Sincronizacion de Pull en red ────────────────────────────────
-- Recibe PULL_START;secs;sender y PULL_CANCEL;sender desde network.lua
function WG.OnNetworkPull(cmd, parts, sender)
    local myName = UnitName("player")
    if cmd == "PULL_START" then
        local secs   = tonumber(parts[2]) or 10
        local secsStr = parts[2] or "?"
        local origin = parts[3] or sender or "?"
        if origin == myName then return end
        applyPullState(true)
        WG.setInfo("Pull en "..secsStr.."s (por "..origin..")", secs + 3)
    elseif cmd == "PULL_CANCEL" then
        local origin = parts[2] or sender or "?"
        if origin == myName then return end
        applyPullState(false)
        WG.setInfo("Pull cancelado por "..origin, 8)
    elseif cmd == "PULL_END" then
        -- Pull finalizo (timer del sender termino)
        local origin = parts[2] or sender or "?"
        applyPullState(false)
        -- No mostrar mensaje al terminar pull normal
    end
end

-- ── Build ─────────────────────────────────────────────────────────
function WG.Build()
    if wFrame then return end

    local W   = 176
    local PAD = 5
    local GAP = 4
    local BH  = 20
    local COL = (W - PAD*2 - GAP) / 2   -- ~76px

    wFrame = CreateFrame("Frame","RaidMarkWidget",UIParent)
    wFrame:SetWidth(W)
    wFrame:SetFrameStrata("HIGH"); wFrame:SetFrameLevel(50)
    wFrame:EnableMouse(true); wFrame:SetMovable(true)
    wFrame:SetClampedToScreen(true)
    wFrame:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize=8, insets={left=3,right=3,top=3,bottom=3}})
    wFrame:SetBackdropColor(0.04,0.04,0.06,0.93)
    wFrame:SetBackdropBorderColor(0.5,0.42,0.2,1)
    wFrame:RegisterForDrag("LeftButton")

    if RaidMarkDB and RaidMarkDB.widgetX then
        wFrame:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",
            RaidMarkDB.widgetX, RaidMarkDB.widgetY)
    else
        wFrame:SetPoint("CENTER",UIParent,"CENTER",300,100)
    end
    wFrame:SetScript("OnDragStart",function()
        if not WG.locked then wFrame:StartMoving() end
    end)
    wFrame:SetScript("OnDragStop",function()
        wFrame:StopMovingOrSizing()
        local _,_,_,x,y = wFrame:GetPoint()
        if RaidMarkDB then RaidMarkDB.widgetX=x; RaidMarkDB.widgetY=y end
    end)
    wFrame:Hide()

    -- ── Barra de titulo con boton X y boton Lock circulo ─────────
    local TITLE_H = 18

    local titleLbl = wFrame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    titleLbl:SetPoint("TOPLEFT",wFrame,"TOPLEFT",6,-4)
    titleLbl:SetText("RaidMark"); titleLbl:SetFont("Fonts\\FRIZQT__.TTF",9,"")
    titleLbl:SetTextColor(0.5,0.75,1,1)

    -- Boton X (cerrar) - esquina superior derecha
    local closeXBtn = CreateFrame("Button",nil,wFrame)
    closeXBtn:SetWidth(14); closeXBtn:SetHeight(14)
    closeXBtn:SetPoint("TOPRIGHT",wFrame,"TOPRIGHT",-4,-3)
    closeXBtn:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize=4, insets={left=1,right=1,top=1,bottom=1}})
    closeXBtn:SetBackdropColor(0.35,0.06,0.06,0.95)
    closeXBtn:SetBackdropBorderColor(0.7,0.15,0.15,1)
    local closeXTxt = closeXBtn:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    closeXTxt:SetAllPoints(closeXBtn)
    closeXTxt:SetText("x"); closeXTxt:SetFont("Fonts\\FRIZQT__.TTF",8,"")
    closeXTxt:SetTextColor(1,0.6,0.6,1)
    closeXBtn:SetScript("OnEnter",function()
        closeXBtn:SetBackdropBorderColor(1,0.3,0.3,1)
        GameTooltip:SetOwner(closeXBtn,"ANCHOR_BOTTOM")
        GameTooltip:SetText("Cerrar Widget"); GameTooltip:Show()
    end)
    closeXBtn:SetScript("OnLeave",function()
        closeXBtn:SetBackdropBorderColor(0.7,0.15,0.15,1); GameTooltip:Hide()
    end)
    closeXBtn:SetScript("OnClick",function() WG.Hide() end)

    -- Boton Lock (circulo) - a la izquierda del X
    local lockCircle = CreateFrame("Button",nil,wFrame)
    lockCircle:SetWidth(14); lockCircle:SetHeight(14)
    lockCircle:SetPoint("RIGHT",closeXBtn,"LEFT",-2,0)
    lockCircle:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize=4, insets={left=1,right=1,top=1,bottom=1}})
    lockCircle:SetBackdropColor(0.12,0.12,0.08,0.95)
    lockCircle:SetBackdropBorderColor(0.38,0.32,0.12,1)
    local lockCircleTxt = lockCircle:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    lockCircleTxt:SetAllPoints(lockCircle)
    lockCircleTxt:SetText("o"); lockCircleTxt:SetFont("Fonts\\FRIZQT__.TTF",8,"")
    lockCircleTxt:SetTextColor(0.6,0.6,0.6,1)
    lockCircle._locked = true

    local function updateLockCircle()
        if WG.locked then
            lockCircle:SetBackdropColor(0.12,0.12,0.08,0.95)
            lockCircle:SetBackdropBorderColor(0.38,0.32,0.12,1)
            lockCircleTxt:SetTextColor(0.55,0.55,0.55,1)
            wFrame:SetBackdropBorderColor(0.5,0.42,0.2,1)
        else
            lockCircle:SetBackdropColor(0.22,0.18,0.04,0.95)
            lockCircle:SetBackdropBorderColor(0.88,0.72,0.08,1)  -- dorado = libre
            lockCircleTxt:SetTextColor(1,0.85,0.2,1)
            wFrame:SetBackdropBorderColor(0.88,0.72,0.08,1)
        end
    end
    lockCircle:SetScript("OnClick",function()
        WG.locked = not WG.locked
        updateLockCircle()
    end)
    lockCircle:SetScript("OnEnter",function()
        lockCircle:SetBackdropBorderColor(1,0.9,0.3,1)
        GameTooltip:SetOwner(lockCircle,"ANCHOR_BOTTOM")
        if WG.locked then
            GameTooltip:SetText("Desbloquear widget")
            GameTooltip:AddLine("Click para mover el widget.",0.7,0.7,0.7,true)
        else
            GameTooltip:SetText("Bloquear widget")
            GameTooltip:AddLine("Borde dorado = movible.",0.7,0.7,0.7,true)
        end
        GameTooltip:Show()
    end)
    lockCircle:SetScript("OnLeave",function()
        updateLockCircle(); GameTooltip:Hide()
    end)
    updateLockCircle()

    local curY = -(TITLE_H + PAD)

    -- ── Fila 1: RC | Assist ───────────────────────────────────────
    local rcBtn = makeWBtn("Ready Check",COL,BH)
    rcBtn:SetPoint("TOPLEFT",wFrame,"TOPLEFT",PAD,curY)

    local assistBtn = makeWBtn("Assist: OFF",COL,BH)
    assistBtn:SetPoint("TOPLEFT",wFrame,"TOPLEFT",PAD+COL+GAP,curY)
    curY = curY - BH - GAP

    -- ── Fila 2: Pull | box segundos ──────────────────────────────
    -- Pull btn estrecho + editbox ancho para que el numero sea visible
    local pullW = 36
    local ebW   = 40   -- ancho fijo suficiente para "60s" claramente visible

    local pullBtn = makeWBtn("Pull",pullW,BH)
    pullBtn:SetPoint("TOPLEFT",wFrame,"TOPLEFT",PAD,curY)
    applyPullState(false)
    pullBtnRef    = pullBtn
    wFrame.pullBtn = pullBtn

    local pullEB = CreateFrame("EditBox","RaidMarkPullEB",wFrame)
    pullEB:SetWidth(ebW); pullEB:SetHeight(BH)
    pullEB:SetPoint("LEFT",pullBtn,"RIGHT",3,0)
    pullEB:SetFont("Fonts\\FRIZQT__.TTF",11,"")
    pullEB:SetTextColor(1,0.95,0.3,1); pullEB:SetAutoFocus(false)
    pullEB:SetMaxLetters(3); pullEB:SetText("10")
    pullEB:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize=4, insets={left=1,right=1,top=1,bottom=1}})
    pullEB:SetBackdropColor(0.06,0.05,0.02,1)  -- fondo levemente dorado para contraste
    pullEB:SetBackdropBorderColor(0.6,0.5,0.2,1)
    pullEB:SetJustifyH("CENTER")
    -- Seleccionar todo el texto al dar foco para evitar acumulacion de digitos
    pullEB:SetScript("OnEditFocusGained", function() pullEB:HighlightText() end)
    pullEB:SetScript("OnEscapePressed",   function() pullEB:ClearFocus() end)
    pullEB:SetScript("OnEnterPressed",    function() pullEB:ClearFocus() end)
    pullEB:SetScript("OnMouseDown",       function() pullEB:SetFocus() end)

    -- Auto-Total 20s (columna derecha fila 2)
    local autoBtn = makeWBtn("Auto-Total 20s",COL,BH)
    autoBtn:SetPoint("TOPLEFT",wFrame,"TOPLEFT",PAD+COL+GAP,curY)
    autoBtn.labelText:SetTextColor(0.55,0.85,1,1)
    setBorder(autoBtn,0.18,0.42,0.68)
    curY = curY - BH - GAP

    -- ── Separador ────────────────────────────────────────────────
    local function makeSep(yPos)
        local s = wFrame:CreateTexture(nil,"ARTWORK")
        s:SetHeight(1)
        s:SetPoint("TOPLEFT",wFrame,"TOPLEFT",PAD,yPos)
        s:SetPoint("TOPRIGHT",wFrame,"TOPRIGHT",-PAD,yPos)
        s:SetTexture(0.35,0.3,0.15,0.65)
        return s
    end
    makeSep(curY); curY = curY - 6

    -- ── Fila 3: Raid Scan label ───────────────────────────────────
    local scanLbl = wFrame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    scanLbl:SetPoint("TOPLEFT",wFrame,"TOPLEFT",PAD,curY)
    scanLbl:SetText("Raid Scan:")
    scanLbl:SetFont("Fonts\\FRIZQT__.TTF",9,"")
    scanLbl:SetTextColor(0.6,0.55,0.28,1)
    curY = curY - 13

    -- ── Fila 4: Resist | Flask Chk ───────────────────────────────
    -- Resist btn: click derecho = dropdown, click izquierdo = ejecutar
    local resistBtn = makeWBtn("Resist",COL,BH)
    resistBtn:SetPoint("TOPLEFT",wFrame,"TOPLEFT",PAD,curY)
    resistBtn.labelText:SetTextColor(0.7,0.7,0.7,1)
    setBorder(resistBtn,0.35,0.35,0.35)
    resistBtnRef = resistBtn
    resistBtn:RegisterForClicks("LeftButtonUp","RightButtonUp")

    local flaskBtn = makeWBtn("Flask Chk",COL,BH)
    flaskBtn:SetPoint("TOPLEFT",wFrame,"TOPLEFT",PAD+COL+GAP,curY)
    flaskBtn.labelText:SetTextColor(0.45,0.7,1,1)
    setBorder(flaskBtn,0.2,0.4,0.7)
    curY = curY - BH - GAP

    -- Dropdown de resistencias (estilo consumables panel)
    local resistDD = CreateFrame("Frame","RaidMarkWidgetResistDD",UIParent)
    resistDD:SetFrameStrata("FULLSCREEN_DIALOG")
    resistDD:SetFrameLevel(200)
    resistDD:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize=6, insets={left=2,right=2,top=2,bottom=2}})
    resistDD:SetBackdropColor(0.05,0.05,0.08,1)
    resistDD:SetBackdropBorderColor(0.5,0.4,0.2,1)
    resistDD:Hide()

    -- Cerrar dropdown al hacer click fuera
    resistDD:SetScript("OnHide",function() resistDD:Hide() end)

    -- Populate dropdown rows (se hace cuando se construyen los items)
    local function buildResistDropdown()
        local CS = RM.Consumables
        if not CS then return end
        local defs = CS.RESIST_DEFS
        if CS.GetResistDefs then defs = CS.GetResistDefs() or CS.RESIST_DEFS end
        if not defs then return end
        local rowH = 17
        resistDD:SetWidth(92)
        resistDD:SetHeight(table.getn(defs)*rowH + 8)
        for ri, rd in ipairs(defs) do
            local rbtn = CreateFrame("Button",nil,resistDD)
            rbtn:SetWidth(88); rbtn:SetHeight(rowH-1)
            rbtn:SetPoint("TOPLEFT",resistDD,"TOPLEFT",2,-(4+(ri-1)*rowH))
            local rfs = rbtn:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
            rfs:SetAllPoints(rbtn); rfs:SetText(rd.label)
            rfs:SetFont("Fonts\\FRIZQT__.TTF",9,"")
            rfs:SetTextColor(rd.r,rd.g,rd.b,1); rfs:SetJustifyH("LEFT")
            local rdi = ri
            local rdDef = rd
            rbtn:SetScript("OnClick",function()
                activeResistIdx = rdi
                resistDD:Hide()
                -- Actualizar boton principal
                resistBtn.labelText:SetText("Res:"..rdDef.label)
                resistBtn.labelText:SetTextColor(rdDef.r,rdDef.g,rdDef.b,1)
                setBorder(resistBtn,rdDef.r*0.75,rdDef.g*0.75,rdDef.b*0.75)
                WG.setInfo("Resist: "..rdDef.label.." seleccionado.")
            end)
            rbtn:SetScript("OnEnter",function() rfs:SetTextColor(1,1,1,1) end)
            rbtn:SetScript("OnLeave",function() rfs:SetTextColor(rdDef.r,rdDef.g,rdDef.b,1) end)
        end
    end

    -- Flask double-click system
    local flaskArmed = false
    local flaskTimer = 0
    local flaskArmedFrame = nil
    local function resetFlaskArmed()
        flaskArmed = false; flaskTimer = 0
        flaskBtn.labelText:SetText("Flask Chk")
        flaskBtn.labelText:SetTextColor(0.45,0.7,1,1)
        setBorder(flaskBtn,0.2,0.4,0.7)
    end

    flaskBtn:SetScript("OnClick",function()
        local CS = RM.Consumables
        if not CS then return end
        if not flaskArmed then
            -- 1er click: ejecutar scan y mostrar resultado
            if CS.scanCount == 0 then if CS.DoScan then CS.DoScan() end end
            local lines = {}
            if CS.DoFlask then lines = CS.DoFlask(false) or {} end
            -- Mostrar resumen en info box
            if table.getn(lines) > 0 then
                WG.setInfo(lines[1].text or "Flask scan listo.", 12)
            end
            -- Armar para 2do click
            flaskArmed = true; flaskTimer = 0
            flaskBtn.labelText:SetText("Flask Chk >>")
            flaskBtn.labelText:SetTextColor(1,0.85,0.1,1)
            setBorder(flaskBtn,0.7,0.55,0.08)
            if flaskArmedFrame then flaskArmedFrame:SetScript("OnUpdate",nil) end
            flaskArmedFrame = CreateFrame("Frame")
            flaskArmedFrame:SetScript("OnUpdate",function()
                flaskTimer = flaskTimer + arg1
                if flaskTimer >= 3 then
                    resetFlaskArmed()
                    flaskArmedFrame:SetScript("OnUpdate",nil)
                end
            end)
        else
            -- 2do click: enviar a /rw
            resetFlaskArmed()
            if flaskArmedFrame then flaskArmedFrame:SetScript("OnUpdate",nil) end
            if CS.DoFlask then CS.DoFlask(true) end
            WG.setInfo("Flask Chk enviado a /rw.")
        end
    end)
    flaskBtn:SetScript("OnEnter",function()
        GameTooltip:SetOwner(flaskBtn,"ANCHOR_BOTTOM")
        GameTooltip:SetText("Flask Checker")
        GameTooltip:AddLine("1er click: preview. 2do click (<3s): envia a /rw.",0.7,0.7,0.7,true)
        GameTooltip:Show()
    end)
    flaskBtn:SetScript("OnLeave",function() GameTooltip:Hide() end)

    -- Resist btn: click derecho = dropdown, click izquierdo = ejecutar (double-click a /rw)
    resistBtn:SetScript("OnClick",function()
        if arg1 == "RightButton" then
            -- Abrir dropdown
            if not resistDD.populated then
                buildResistDropdown(); resistDD.populated = true
            end
            if resistDD:IsVisible() then
                resistDD:Hide()
            else
                resistDD:ClearAllPoints()
                resistDD:SetPoint("TOPLEFT",resistBtn,"BOTTOMLEFT",0,-2)
                resistDD:Show()
            end
            return
        end
        -- Click izquierdo: ejecutar
        local CS = RM.Consumables
        if not CS then return end
        if not activeResistIdx then
            WG.setInfo("Click derecho para elegir resistencia.")
            return
        end
        local defs = CS.RESIST_DEFS
        if CS.GetResistDefs then defs = CS.GetResistDefs() or CS.RESIST_DEFS end
        local rd = defs[activeResistIdx]
        if not rd then return end

        if not resistArmed then
            -- 1er click: scan y preview
            if CS.scanCount == 0 then if CS.DoScan then CS.DoScan() end end
            local lines = {}
            if CS.DoResist then lines = CS.DoResist(rd, false) or {} end
            if table.getn(lines) > 0 then
                WG.setInfo((lines[1].text or "Resist scan listo."), 12)
            end
            resistArmed = true; resistArmedTimer = 0
            resistBtn.labelText:SetText("Res:"..rd.label.." >>")
            if resistArmedFrame then resistArmedFrame:SetScript("OnUpdate",nil) end
            resistArmedFrame = CreateFrame("Frame")
            resistArmedFrame:SetScript("OnUpdate",function()
                resistArmedTimer = resistArmedTimer + arg1
                if resistArmedTimer >= 3 then
                    resetResistArmed(); resistArmedFrame:SetScript("OnUpdate",nil)
                end
            end)
        else
            -- 2do click: enviar a /rw
            resetResistArmed()
            if resistArmedFrame then resistArmedFrame:SetScript("OnUpdate",nil) end
            if CS.DoResist then CS.DoResist(rd, true) end
            WG.setInfo("Resist "..rd.label.." enviado a /rw.")
        end
    end)
    resistBtn:SetScript("OnEnter",function()
        GameTooltip:SetOwner(resistBtn,"ANCHOR_BOTTOM")
        GameTooltip:SetText("Resist Checker")
        GameTooltip:AddLine("Click derecho: elegir tipo de resist.",0.7,0.7,0.7,true)
        GameTooltip:AddLine("1er click izq: preview. 2do click (<3s): /rw.",0.7,0.7,0.7,true)
        GameTooltip:Show()
    end)
    resistBtn:SetScript("OnLeave",function() GameTooltip:Hide() end)

    -- ── Separador + InfoBox scrolleable ──────────────────────────
    makeSep(curY); curY = curY - 4

    -- ScrollFrame invisible para el info box
    local infoScrollH = 36
    local infoScroll = CreateFrame("ScrollFrame",nil,wFrame)
    infoScroll:SetWidth(W - PAD*2)
    infoScroll:SetHeight(infoScrollH)
    infoScroll:SetPoint("TOPLEFT",wFrame,"TOPLEFT",PAD,curY)
    infoScroll:EnableMouseWheel(true)
    infoScroll:SetScript("OnMouseWheel",function()
        local delta = arg1
        local cur = infoScroll:GetVerticalScroll()
        local mx  = infoScroll:GetVerticalScrollRange()
        local nv  = cur - delta*14
        if nv < 0 then nv=0 end
        if nv > mx then nv=mx end
        infoScroll:SetVerticalScroll(nv)
    end)

    local infoContent = CreateFrame("Frame",nil,infoScroll)
    infoContent:SetWidth(W - PAD*2 - 4)
    infoContent:SetHeight(infoScrollH)
    infoScroll:SetScrollChild(infoContent)

    local infoLbl = infoContent:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    infoLbl:SetPoint("TOPLEFT",infoContent,"TOPLEFT",0,0)
    infoLbl:SetWidth(W - PAD*2 - 4)
    infoLbl:SetFont("Fonts\\FRIZQT__.TTF",9,"")
    infoLbl:SetTextColor(0.38,0.48,0.38,0.75)
    infoLbl:SetJustifyH("LEFT")
    infoLbl:SetText("")
    WG.infoLbl   = infoLbl
    WG.infoScroll = infoScroll
    curY = curY - infoScrollH - PAD

    -- Altura total del frame
    wFrame:SetHeight(math.abs(curY) + PAD + 2)

    -- ════════════════ SCRIPTS ════════════════════════════════════

    -- Ready Check
    local function updateRcBtn()
        local ok = RM.Permissions.IsRL() or
                   (RM.Permissions.IsAssist() and RM.state.assistCanMove)
        if ok then
            rcBtn.labelText:SetTextColor(0.95,0.82,0.18,1)
            setBorder(rcBtn,0.62,0.5,0.08); rcBtn:EnableMouse(true)
        else
            rcBtn.labelText:SetTextColor(0.32,0.32,0.32,1)
            setBorder(rcBtn,0.28,0.28,0.28); rcBtn:EnableMouse(false)
        end
    end
    WG.updateRcBtnState = updateRcBtn

    rcBtn:SetScript("OnClick",function()
        if RM.Consumables and RM.Consumables.SendReadyCheckRequest then
            RM.Consumables.SendReadyCheckRequest()
        end
    end)
    rcBtn:SetScript("OnEnter",function()
        GameTooltip:SetOwner(rcBtn,"ANCHOR_BOTTOM")
        GameTooltip:SetText("Ready Check Remoto")
        GameTooltip:AddLine("RL: directo. Assist: solicita al RL.",0.7,0.7,0.7,true)
        GameTooltip:Show()
    end)
    rcBtn:SetScript("OnLeave",function() GameTooltip:Hide() end)

    -- Pull: usa SlashCmdList["PULL"] nativo del juego
    -- Funcion helper compartida: ejecutar slash command nativo
    local function execSlash(cmd)
        local eb = DEFAULT_CHAT_FRAME.editBox
        if eb then
            eb:SetText(cmd)
            ChatEdit_SendText(eb)
            eb:SetText("")
            eb:ClearFocus()
        end
    end
    WG.execSlash = execSlash  -- exponer por si se necesita

    pullBtn:SetScript("OnClick",function()
        local myName = UnitName("player")
        -- Verificar permisos: RL o Assist con permisos
        local hasPerms = RM.Permissions.IsRL() or
                         (RM.Permissions.IsAssist() and RM.state.assistCanMove)

        if WG.pullActive then
            -- Cancelar pull: permitido a cualquiera que lo haya lanzado
            -- (no bloqueamos cancel por permisos - importante para desincronizacion)
            execSlash("/pull cancel")
            applyPullState(false)
            WG.setInfo("Pull cancelado.")
            if RM.Network and RM.Network.SendRaw then
                RM.Network.SendRaw("PULL_CANCEL;"..myName)
            end
        else
            -- Verificar que este en party/raid
            if GetNumRaidMembers() == 0 and GetNumPartyMembers() == 0 then
                WG.setInfo("Debes estar en party/raid primero.", 4)
                return
            end
            if not hasPerms then
                WG.setInfo("Sin permisos de RL/Asist para pull.", 4)
                return
            end
            pullEB:ClearFocus()
            local secs = tonumber(pullEB:GetText()) or 10
            if secs < 1  then secs = 1  end
            if secs > 60 then secs = 60 end
            pullEB:SetText(tostring(secs))
            execSlash("/pull "..secs)
            applyPullState(true)
            WG.setInfo("Pull en "..secs.."s lanzado.")
            if RM.Network and RM.Network.SendRaw then
                RM.Network.SendRaw("PULL_START;"..secs..";"..myName)
            end
            -- Timer local: cuando el pull termina, resetear boton y broadcast PULL_END
            local pullEndTimer = 0
            local pullEndSecs  = secs
            local pullMyName   = myName
            local pullEndFrame = CreateFrame("Frame")
            pullEndFrame:SetScript("OnUpdate",function()
                pullEndTimer = pullEndTimer + arg1
                if pullEndTimer >= pullEndSecs then
                    -- Solo resetear si seguimos siendo el dueno del pull activo
                    if WG.pullActive then
                        applyPullState(false)
                        if RM.Network and RM.Network.SendRaw then
                            RM.Network.SendRaw("PULL_END;"..pullMyName)
                        end
                    end
                    pullEndFrame:SetScript("OnUpdate",nil)
                end
            end)
        end
    end)
    pullBtn:SetScript("OnEnter",function()
        GameTooltip:SetOwner(pullBtn,"ANCHOR_BOTTOM")
        if WG.pullActive then
            GameTooltip:SetText("Cancelar Pull")
            GameTooltip:AddLine("Ejecuta /pull cancel.",0.7,0.7,0.7,true)
        else
            GameTooltip:SetText("Pull Timer")
            GameTooltip:AddLine("Ejecuta /pull XX con el numero del box.",0.7,0.7,0.7,true)
        end
        GameTooltip:Show()
    end)
    pullBtn:SetScript("OnLeave",function() GameTooltip:Hide() end)

    -- Auto-Total 20s
    autoBtn:SetScript("OnClick",function()
        if RM.MapFrame and RM.MapFrame.RunAutoTotal then
            RM.MapFrame.RunAutoTotal()
            WG.setInfo("Auto-Total (20s) lanzado.")
        else
            RM.Msg("Auto-Asignar no disponible.",1,0.5,0.2)
        end
    end)
    autoBtn:SetScript("OnEnter",function()
        GameTooltip:SetOwner(autoBtn,"ANCHOR_BOTTOM")
        GameTooltip:SetText("Auto-Total (20s)")
        GameTooltip:AddLine("Igual al boton Auto-Total del panel principal.",0.7,0.7,0.7,true)
        GameTooltip:Show()
    end)
    autoBtn:SetScript("OnLeave",function() GameTooltip:Hide() end)

    -- Assist ON/OFF
    local function updateAssistBtn()
        if RM.state.assistCanMove then
            assistBtn.labelText:SetText("Assist: ON")
            assistBtn.labelText:SetTextColor(0.28,1,0.38,1)
            setBorder(assistBtn,0.18,0.58,0.2)
        else
            assistBtn.labelText:SetText("Assist: OFF")
            assistBtn.labelText:SetTextColor(0.72,0.28,0.28,1)
            setBorder(assistBtn,0.5,0.18,0.18)
        end
    end
    WG.updateAssistBtn = updateAssistBtn
    updateAssistBtn()

    assistBtn:SetScript("OnClick",function()
        if not RM.Permissions.IsRL() then
            RM.Msg("Solo el RL puede cambiar permisos de Assist.",1,0.3,0.3); return
        end
        RM.state.assistCanMove = not RM.state.assistCanMove
        RM.Network.SendPermissions(RM.state.assistCanMove)
        updateAssistBtn()
        if RM.MapFrame and RM.MapFrame.UpdateAssistBtn then
            RM.MapFrame.UpdateAssistBtn()
        end
        WG.setInfo("Assist: "..(RM.state.assistCanMove and "ON" or "OFF"))
    end)
    assistBtn:SetScript("OnEnter",function()
        GameTooltip:SetOwner(assistBtn,"ANCHOR_BOTTOM")
        GameTooltip:SetText("Assist ON/OFF")
        GameTooltip:AddLine("Igual que el boton del panel principal.",0.7,0.7,0.7,true)
        GameTooltip:Show()
    end)
    assistBtn:SetScript("OnLeave",function() GameTooltip:Hide() end)

    -- Actualizar estados cada segundo
    local stateT = 0
    wFrame:SetScript("OnUpdate",function()
        stateT = stateT + arg1
        if stateT >= 1 then
            stateT = 0; updateRcBtn(); updateAssistBtn()
        end
    end)

    updateRcBtn()
end

-- ── Show / Hide / Toggle ─────────────────────────────────────────
function WG.Show()
    if not wFrame then WG.Build() end
    wFrame:Show(); WG.visible = true
    applyPendingMsg()
end
function WG.Hide()
    if wFrame then wFrame:Hide() end; WG.visible = false
end
function WG.Toggle()
    if WG.visible then WG.Hide() else WG.Show() end
end

-- ── Persistencia de visibilidad del widget ────────────────────────
-- Guarda si el widget estaba abierto para restaurarlo al recargar
local wPersistFrame = CreateFrame("Frame","RaidMarkWidgetPersist")
wPersistFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
wPersistFrame:SetScript("OnEvent",function()
    -- Esperar un frame para que RaidMarkDB este listo
    local waitFrame = CreateFrame("Frame")
    local waited = false
    waitFrame:SetScript("OnUpdate",function()
        if waited then
            waitFrame:SetScript("OnUpdate",nil)
            return
        end
        waited = true
        -- Restaurar visibilidad si estaba abierto
        if RaidMarkDB and RaidMarkDB.widgetOpen then
            WG.Show()
        end
    end)
end)

-- Hook WG.Show y WG.Hide para guardar estado
local _origShow = WG.Show
local _origHide = WG.Hide

function WG.Show()
    _origShow()
    if RaidMarkDB then RaidMarkDB.widgetOpen = true end
end

function WG.Hide()
    _origHide()
    if RaidMarkDB then RaidMarkDB.widgetOpen = false end
end
