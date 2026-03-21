-- ============================================================
--  RaidMark -- scenes.lua  (reescrito limpio)
-- ============================================================
local RM = RaidMark
RM.Scenes = {}
local SC = RM.Scenes

SC.currentGrand = 1
SC.currentSlot  = nil

local function ensureDB()
    if not RaidMarkSceneDB then RaidMarkSceneDB = {} end
    for g = 1, 10 do
        if not RaidMarkSceneDB[g] then RaidMarkSceneDB[g] = {} end
    end
end
local function getSlotData(grand, slot)
    ensureDB(); return RaidMarkSceneDB[grand] and RaidMarkSceneDB[grand][slot]
end
local function setSlotData(grand, slot, data)
    ensureDB(); RaidMarkSceneDB[grand][slot] = data
end
local function captureScene()
    local snap = {}
    for id, data in pairs(RM.state.placedIcons) do
        snap[id] = { iconType=data.iconType, x=data.x, y=data.y,
            label=data.label or "", colorR=data.colorR, colorG=data.colorG,
            colorB=data.colorB, stretchW=data.stretchW, stretchH=data.stretchH }
    end
    return snap
end
local function timestamp() return date("%d/%m %H:%M") end

function SC.Save()
    -- Todos pueden guardar localmente (RL, Assist, Raider)
    -- Solo el RL puede cargar al lienzo (en SC.Load)
    if not SC.currentSlot then
        if RM.MapFrame and RM.MapFrame.ConsoleMsg then RM.MapFrame.ConsoleMsg("Selecciona un slot (1-4).", 1,0.5,0.2) end; return
    end
    -- Verificar: si el lienzo tiene fakes pero NO estamos en modo offline, bloquear
    local hasFakes = false
    for _, ic in pairs(RM.state.placedIcons) do
        if RM.IsOfflineRoleIcon and RM.IsOfflineRoleIcon(ic.iconType) then
            hasFakes = true; break
        end
    end
    if hasFakes and not RM.state.offlineMode then
        if RM.MapFrame and RM.MapFrame.ConsoleMsg then
            RM.MapFrame.ConsoleMsg(
                "Para guardar posiciones debes estar en Modo Offline.",
                1, 0.4, 0.1)
        end
        return
    end
    -- Contar iconos y detectar mapa de posicionamiento
    local iconCount = 0
    local isPosiMap = false
    for _, ic in pairs(RM.state.placedIcons) do
        iconCount = iconCount + 1
        if RM.IsOfflineRoleIcon and RM.IsOfflineRoleIcon(ic.iconType) then
            isPosiMap = true
        end
    end
    -- Si lienzo completamente vacio: borrar el slot (limpiar)
    if iconCount == 0 then
        setSlotData(SC.currentGrand, SC.currentSlot, nil)
        SC.RefreshUI()
        if RM.MapFrame and RM.MapFrame.ConsoleMsg then RM.MapFrame.ConsoleMsg("Slot "..SC.currentSlot.." limpiado.", 0.7,0.7,0.7) end
        return
    end
    setSlotData(SC.currentGrand, SC.currentSlot, {
        icons    = captureScene(),
        mapKey   = RM.state.currentMap or "",
        savedAt  = timestamp(),
        nextId   = RM.state.nextIconId,
        hasIcons = true,
        isPosi   = isPosiMap,
    })
    SC.RefreshUI()
    if RM.MapFrame and RM.MapFrame.ConsoleMsg then RM.MapFrame.ConsoleMsg("Slot "..SC.currentSlot.." guardado ("..timestamp()..")", 0.4,1,0.6) end
end

function SC.Load(grand, slot)
    -- En modo offline cualquiera puede cargar (es local, no broadcastea)
    local inOffline = RM.state and RM.state.offlineMode
    if not inOffline and not RM.Permissions.IsRL() then
        if RM.MapFrame and RM.MapFrame.ConsoleMsg then
            RM.MapFrame.ConsoleMsg("Solo el RL puede cargar escenas al lienzo.", 1,0.3,0.3)
        end
        return
    end
    local data = getSlotData(grand, slot)
    if not data then return end
    RM.ClearAll()
    if not inOffline then RM.Network.SendClear() end
    if data.mapKey and data.mapKey ~= "" then
        RM.SetMap(data.mapKey)
        if not inOffline then RM.Network.SendMapChange(data.mapKey) end
    end
    if data.nextId then RM.state.nextIconId = data.nextId end
    for id, ic in pairs(data.icons) do
        RM.Icons.ApplyPlace(id, ic.iconType, ic.x, ic.y, ic.label,
            ic.colorR, ic.colorG, ic.colorB, ic.stretchW, ic.stretchH)
        -- Fakes (iconos offline) solo locales, NO broadcastear
        local isFake = RM.IsOfflineRoleIcon and RM.IsOfflineRoleIcon(ic.iconType)
        if not isFake then
            RM.Network.SendPlace(id, ic.iconType, ic.x, ic.y, ic.label,
                ic.colorR or 1, ic.colorG or 1, ic.colorB or 1,
                ic.stretchW or 0, ic.stretchH or 0)
            if ic.stretchW and ic.stretchW > 0 then
                RM.Network.SendStretch(id, ic.stretchW, ic.stretchH or ic.stretchW)
            end
        end
    end
    SC.currentSlot = nil; SC.RefreshUI()

    -- Notificar si es mapa de posicionamiento
    if data.isPosi then
        if RM.MapFrame and RM.MapFrame.ConsoleMsg then
            RM.MapFrame.ConsoleMsg(
                "Slot de POSICIONAMIENTO cargado. Selecciona el slot y presiona Sync P.",
                1, 0.85, 0.2)
        end
    end
end

-- Sync de posicionamiento (Idea C):
-- Lee posiciones del slot SELECCIONADO (rojo). Seguro de llamar N veces.
-- Paso 1: elimina raiders reales en posiciones de fakes (evita duplicados)
-- Paso 2: coloca raiders frescos desde el snapshot
function SC.SyncPositioning()
    if not RM.Permissions.IsRL() then return end

    -- Usar el slot actualmente seleccionado (rojo)
    if not SC.currentSlot then
        if RM.MapFrame and RM.MapFrame.ConsoleMsg then
            RM.MapFrame.ConsoleMsg(
                "Selecciona un slot (1-4) antes de usar Sync P.",
                1, 0.6, 0.2)
        end
        return
    end

    local data = getSlotData(SC.currentGrand, SC.currentSlot)
    if not data or not data.isPosi then
        if RM.MapFrame and RM.MapFrame.ConsoleMsg then
            RM.MapFrame.ConsoleMsg(
                "El slot seleccionado no es un mapa de posicionamiento (slot verde).",
                1, 0.5, 0.2)
        end
        return
    end
    if not data.icons then return end

    local ROLE_TO_OFFLINE = {
        TANK="OFFLINE_TANK", HEAL="OFFLINE_HEAL",
        DPS_M="OFFLINE_DPSM", DPS_R="OFFLINE_DPSR"
    }

    -- Leer posiciones del snapshot (fuente de verdad)
    local roleSlots = {}
    for _, ic in pairs(data.icons) do
        if RM.IsOfflineRoleIcon and RM.IsOfflineRoleIcon(ic.iconType) then
            if not roleSlots[ic.iconType] then roleSlots[ic.iconType] = {} end
            table.insert(roleSlots[ic.iconType], {x=ic.x, y=ic.y})
        end
    end

    -- Paso 1: construir set de raiders YA en el lienzo (colocados manualmente)
    -- Estos tienen PRIORIDAD y no se tocan ni se duplican
    local alreadyPlaced = {}  -- nombre -> true
    for _, ic in pairs(RM.state.placedIcons) do
        if ic.label and ic.label ~= "" and not ic.hidden then
            alreadyPlaced[ic.label] = true
        end
    end

    -- Construir set de posiciones ya ocupadas por raiders en el lienzo
    local occupiedPos = {}
    for _, ic2 in pairs(RM.state.placedIcons) do
        if ic2.label and ic2.label ~= "" and not ic2.hidden then
            occupiedPos[string.format("%.4f,%.4f", ic2.x, ic2.y)] = true
        end
    end

    -- Paso 2: colocar raiders que NO esten en el lienzo
    -- Para cada raider, busca el PRIMER slot libre de su rol (no el siguiente en orden)
    -- Asi si Juan ocupa slot 1, Pepito puede ir al slot 2 sin perder su turno
    local usedSlots = {}  -- offType -> set de indices ya usados

    if RM.Roster and RM.Roster.members then
        for name, mdata in pairs(RM.Roster.members) do
            if not alreadyPlaced[name] then
                local role    = RM.state.memberRoles[name]
                local offType = role and ROLE_TO_OFFLINE[role]
                local slots   = offType and roleSlots[offType]
                if slots then
                    if not usedSlots[offType] then usedSlots[offType] = {} end
                    -- Buscar el primer slot libre (no ocupado por raider en lienzo
                    -- y no ya asignado en esta pasada de Sync P)
                    local placed = false
                    for idx, pos in ipairs(slots) do
                        if not usedSlots[offType][idx] then
                            local posKey = string.format("%.4f,%.4f", pos.x, pos.y)
                            if not occupiedPos[posKey] then
                                -- Slot libre: colocar raider aqui
                                usedSlots[offType][idx] = true
                                occupiedPos[posKey] = true  -- marcar ocupado para esta pasada
                                local cf = (mdata and mdata.classFile) or "UNKNOWN"
                                local id = RM.NextId()
                                RM.Icons.ApplyPlace(id, "MEMBER_"..cf, pos.x, pos.y, name)
                                RM.Network.SendPlace(id, "MEMBER_"..cf, pos.x, pos.y, name, 1,1,1,0,0)
                                placed = true
                                break
                            else
                                -- Posicion ocupada: marcar este slot como usado y seguir buscando
                                usedSlots[offType][idx] = true
                            end
                        end
                    end
                    -- Si placed=false, no habia slots disponibles para este raider
                end
            end
        end
    end
end


function SC.SelectSlot(slot)
    SC.currentSlot = (SC.currentSlot == slot) and nil or slot
    SC.RefreshUI()
end
function SC.SetGrand(g)
    SC.currentGrand = g; SC.currentSlot = nil; SC.RefreshUI()
end

SC.ui = {}

function SC.BuildUI(toolbar, anchorRight, makeToolbarBtn)
    local SLOT_W = 26
    local GAP    = 3

    local sceneBar = CreateFrame("Frame", "RaidMarkSceneBar", toolbar)
    sceneBar:SetHeight(24)
    -- S(28) + B(28) + sep + 4 slots(26) + GS(50) + gaps + padding
    sceneBar:SetWidth(8 + 28 + GAP + 28 + GAP + 6 + 4*(SLOT_W+GAP) + 8 + 50)
    sceneBar:SetPoint("RIGHT", anchorRight, "LEFT", -12, 0)
    sceneBar:SetFrameLevel(toolbar:GetFrameLevel() + 1)

    local ix = 0
    local function addBtn(lbl, w)
        local b = makeToolbarBtn(lbl, w)
        b:SetParent(sceneBar)
        b:ClearAllPoints()
        b:SetPoint("LEFT", sceneBar, "LEFT", ix, 0)
        ix = ix + w + GAP
        return b
    end

    -- Sep izquierdo
    local s1 = sceneBar:CreateTexture(nil,"ARTWORK")
    s1:SetWidth(1); s1:SetHeight(22)
    s1:SetPoint("LEFT", sceneBar, "LEFT", 0, 0)
    s1:SetTexture(0.4, 0.35, 0.2, 0.6)
    ix = 6

    -- [S] disquete
    local saveBtn = addBtn("[S]", 28)
    saveBtn.labelText:SetTextColor(1, 0.85, 0.1, 1)
    saveBtn:SetScript("OnClick", function() SC.Save() end)
    saveBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(saveBtn,"ANCHOR_BOTTOM")
        GameTooltip:SetText("Guardar escena")
        GameTooltip:AddLine("Selecciona un slot primero", 0.7,0.7,0.7,true)
        GameTooltip:Show()
    end)
    saveBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- [B] borrar slot seleccionado (con confirmacion)
    local deletePending = false  -- true = esperando segundo click
    local deleteBtn = addBtn("[B]", 28)
    deleteBtn.labelText:SetTextColor(1, 0.3, 0.3, 1)
    deleteBtn:SetScript("OnClick", function()
        if not SC.currentSlot then
            if RM.MapFrame and RM.MapFrame.ConsoleMsg then
                RM.MapFrame.ConsoleMsg("Selecciona un slot para borrar.", 1,0.5,0.2)
            end
            deletePending = false
            return
        end
        local d = getSlotData(SC.currentGrand, SC.currentSlot)
        if not d then
            if RM.MapFrame and RM.MapFrame.ConsoleMsg then
                RM.MapFrame.ConsoleMsg("El slot "..SC.currentSlot.." ya esta vacio.", 0.7,0.7,0.7)
            end
            deletePending = false
            return
        end
        if not deletePending then
            -- Primer click: pedir confirmacion
            deletePending = true
            deleteBtn.labelText:SetTextColor(1, 0.7, 0.1, 1)
            deleteBtn:SetBackdropBorderColor(1, 0.6, 0.1, 1)
            if RM.MapFrame and RM.MapFrame.ConsoleMsg then
                RM.MapFrame.ConsoleMsg(
                    "Seguro de borrar slot GS"..SC.currentGrand.."-"..SC.currentSlot.."? Click [B] de nuevo para confirmar.",
                    1, 0.6, 0.1)
            end
        else
            -- Segundo click: borrar
            deletePending = false
            deleteBtn.labelText:SetTextColor(1, 0.3, 0.3, 1)
            deleteBtn:SetBackdropBorderColor(0.5, 0.42, 0.22, 0.9)
            setSlotData(SC.currentGrand, SC.currentSlot, nil)
            SC.currentSlot = nil
            SC.RefreshUI()
            if RM.MapFrame and RM.MapFrame.ConsoleMsg then
                RM.MapFrame.ConsoleMsg("Slot borrado.", 0.6, 0.6, 0.6)
            end
        end
    end)
    -- Cancelar pending si se mueve el mouse fuera
    deleteBtn:SetScript("OnLeave", function()
        if deletePending then
            deletePending = false
            deleteBtn.labelText:SetTextColor(1, 0.3, 0.3, 1)
            deleteBtn:SetBackdropBorderColor(0.5, 0.42, 0.22, 0.9)
        end
        GameTooltip:Hide()
    end)
    deleteBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(deleteBtn,"ANCHOR_BOTTOM")
        GameTooltip:SetText("Borrar slot seleccionado")
        GameTooltip:AddLine("Primer click = confirmar | Segundo click = borrar", 0.7,0.7,0.7,true)
        GameTooltip:Show()
    end)

    local s2 = sceneBar:CreateTexture(nil,"ARTWORK")
    s2:SetWidth(1); s2:SetHeight(18)
    s2:SetPoint("LEFT", sceneBar, "LEFT", ix, 0)
    s2:SetTexture(0.4, 0.35, 0.2, 0.6)
    ix = ix + 5

    -- Slots 1-4
    SC.ui.slotBtns = {}
    SC.ui.slotChecks = {}   -- FontStrings "v" sobre cada slot
    for i = 1, 4 do
        local sb = addBtn(tostring(i), SLOT_W)
        SC.ui.slotBtns[i] = sb
        -- "v" flotante centrada encima del boton
        local chk = sceneBar:CreateFontString(nil,"OVERLAY","GameFontNormal")
        chk:SetPoint("BOTTOM", sb, "TOP", 0, 1)
        chk:SetText("")
        chk:SetTextColor(1, 0.15, 0.15, 1)
        SC.ui.slotChecks[i] = chk
        local ci = i
        sb:SetScript("OnClick", function()
            local d = getSlotData(SC.currentGrand, ci)
            if d and SC.currentSlot == ci then
                -- Doble click: RL puede cargar siempre, todos pueden en offline
                if RM.Permissions.IsRL() or (RM.state and RM.state.offlineMode) then
                    SC.Load(SC.currentGrand, ci)
                else
                    if RM.MapFrame and RM.MapFrame.ConsoleMsg then
                        RM.MapFrame.ConsoleMsg("Solo el RL puede cargar al lienzo.", 1,0.3,0.3)
                    end
                end
            else
                SC.SelectSlot(ci)
            end
        end)
        sb:SetScript("OnEnter", function()
            local d = getSlotData(SC.currentGrand, ci)
            GameTooltip:SetOwner(sb,"ANCHOR_BOTTOM")
            if d then
                GameTooltip:SetText("GS"..SC.currentGrand.." Slot "..ci)
                GameTooltip:AddLine("Guardado: "..d.savedAt, 0.9,0.9,0.5,true)
                GameTooltip:AddLine("Mapa: "..(d.mapKey~="" and d.mapKey or "Sin mapa"), 0.6,0.8,1,true)
                if SC.currentSlot == ci then
                    if RM.Permissions.IsRL() then
                        GameTooltip:AddLine("Click de nuevo = CARGAR", 0.4,1,0.4,true)
                        GameTooltip:AddLine("[S] = Sobreescribir", 1,0.7,0.3,true)
                    else
                        GameTooltip:AddLine("[S] = Sobreescribir (guardado local)", 1,0.7,0.3,true)
                    end
                else
                    GameTooltip:AddLine("Click para seleccionar", 0.7,0.7,0.7,true)
                end
            else
                GameTooltip:SetText("Slot "..ci.." (vacio)")
                GameTooltip:AddLine("Selecciona y presiona [S]", 0.7,0.7,0.7,true)
            end
            GameTooltip:Show()
        end)
        sb:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    local s3 = sceneBar:CreateTexture(nil,"ARTWORK")
    s3:SetWidth(1); s3:SetHeight(18)
    s3:SetPoint("LEFT", sceneBar, "LEFT", ix, 0)
    s3:SetTexture(0.4, 0.35, 0.2, 0.6)
    ix = ix + 5

    -- GrandSlot btn
    local gsBtn = addBtn("GS1 v", 50)
    gsBtn.labelText:SetTextColor(0.7, 0.9, 1, 1)
    SC.ui.gsBtn = gsBtn
    gsBtn:SetScript("OnClick", function() SC.ToggleGrandDropdown(gsBtn) end)
    gsBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(gsBtn,"ANCHOR_BOTTOM")
        GameTooltip:SetText("GrandSlot: "..SC.currentGrand)
        GameTooltip:AddLine("10 grupos x 4 slots", 0.7,0.7,0.7,true)
        GameTooltip:Show()
    end)
    gsBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Dropdown GrandSlot
    local gsDD = CreateFrame("Frame","RaidMarkGrandSlotDD",UIParent)
    gsDD:SetWidth(130); gsDD:SetHeight(10*26+12)
    gsDD:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8X8",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize=10, insets={left=3,right=3,top=3,bottom=3} })
    gsDD:SetBackdropColor(0.04,0.04,0.05,1.0)
    gsDD:SetBackdropBorderColor(0.7,0.9,1,1)
    gsDD:EnableMouse(true); gsDD:Hide()
    gsDD:SetFrameStrata("FULLSCREEN_DIALOG"); gsDD:SetFrameLevel(160)

    local gsOv = CreateFrame("Frame","RaidMarkGSOv",UIParent)
    gsOv:SetAllPoints(UIParent); gsOv:SetFrameStrata("FULLSCREEN")
    gsOv:SetFrameLevel(150); gsOv:EnableMouse(true); gsOv:Hide()
    gsOv:SetScript("OnMouseDown", function() gsDD:Hide(); gsOv:Hide() end)

    local function countFilled(g)
        local n=0; ensureDB()
        if RaidMarkSceneDB[g] then
            for s=1,4 do if RaidMarkSceneDB[g][s] then n=n+1 end end
        end
        return n
    end

    for g = 1, 10 do
        local row = CreateFrame("Button",nil,gsDD)
        row:SetHeight(24); row:SetWidth(118)
        row:SetPoint("TOPLEFT",gsDD,"TOPLEFT", 6, -(6+(g-1)*26))
        row:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8X8",
            edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize=6, insets={left=2,right=2,top=2,bottom=2} })
        row:SetBackdropColor(0.08,0.08,0.10,1)
        row:SetBackdropBorderColor(0.3,0.3,0.4,1)
        local rhl = row:CreateTexture(nil,"HIGHLIGHT")
        rhl:SetAllPoints(row); rhl:SetTexture(1,1,1,0.12)
        local rfs = row:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
        rfs:SetPoint("LEFT",row,"LEFT",6,0); rfs:SetText("GrandSlot "..g)
        rfs:SetTextColor(0.85,0.85,1,1)
        local rdot = row:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
        rdot:SetPoint("RIGHT",row,"RIGHT",-6,0)
        local cg = g
        row:SetScript("OnClick", function()
            SC.SetGrand(cg); gsBtn.labelText:SetText("GS"..cg.." v")
            gsDD:Hide(); gsOv:Hide()
        end)
        row:SetScript("OnEnter", function()
            GameTooltip:SetOwner(row,"ANCHOR_RIGHT")
            GameTooltip:SetText("GrandSlot "..cg)
            GameTooltip:AddLine(countFilled(cg).." / 4 ocupados",0.7,0.9,0.7,true)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        row:EnableMouse(true)
        row.refresh = function()
            local n = countFilled(cg)
            rdot:SetText(n>0 and (n.."/4") or ""); rdot:SetTextColor(1,0.85,0.2,1)
            if cg == SC.currentGrand then
                row:SetBackdropBorderColor(0.4,0.8,1,1); rfs:SetTextColor(1,1,1,1)
            else
                row:SetBackdropBorderColor(0.3,0.3,0.4,1); rfs:SetTextColor(0.85,0.85,1,1)
            end
        end
        SC.ui["gsRow"..g] = row
    end

    function SC.ToggleGrandDropdown(anchor)
        if gsDD:IsVisible() then gsDD:Hide(); gsOv:Hide(); return end
        for g=1,10 do
            local r=SC.ui["gsRow"..g]; if r and r.refresh then r.refresh() end
        end
        gsDD:ClearAllPoints()
        gsDD:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -4)
        gsDD:Show(); gsOv:Show()
    end

    SC.ui.gsDD = gsDD
    SC.RefreshUI()
end

function SC.RefreshUI()
    for i = 1, 4 do
        local btn = SC.ui.slotBtns  and SC.ui.slotBtns[i]
        local chk = SC.ui.slotChecks and SC.ui.slotChecks[i]
        if btn then
            local d          = getSlotData(SC.currentGrand, i)
            local sel        = (SC.currentSlot == i)
            local hasContent = d and d.hasIcons

            -- Color del boton segun contenido (nunca cambia por seleccion)
            if hasContent then
                if d.isPosi then
                    btn:SetBackdropColor(0.05,0.25,0.05,1)
                    btn:SetBackdropBorderColor(0.2,1,0.2,1)
                    btn.labelText:SetTextColor(0.4,1,0.4,1)
                else
                    btn:SetBackdropColor(0.08,0.08,0.10,1)
                    btn:SetBackdropBorderColor(1,0.85,0.0,1)
                    btn.labelText:SetTextColor(1,0.95,0.3,1)
                end
            else
                btn:SetBackdropColor(0.08,0.08,0.10,1)
                btn:SetBackdropBorderColor(0.5,0.42,0.22,0.9)
                btn.labelText:SetTextColor(0.7,0.7,0.7,1)
            end

            -- "v" encima: roja=seleccionado vacio, naranja=seleccionado con contenido
            if chk then
                if sel and hasContent then
                    chk:SetText("v"); chk:SetTextColor(1, 0.55, 0.0, 1)  -- naranja
                elseif sel then
                    chk:SetText("v"); chk:SetTextColor(1, 0.15, 0.15, 1) -- rojo
                else
                    chk:SetText("")
                end
            end
        end
    end
    if SC.ui.gsBtn then SC.ui.gsBtn.labelText:SetText("GS"..SC.currentGrand.." v") end
end

function SC.Init() ensureDB() end
