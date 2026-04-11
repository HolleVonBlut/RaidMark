-- ============================================================
--  RaidMark -- consumables.lua
--  Panel de Consumibles de Raid
--  REQUIERE: RABuffs instalado (RAB_Buffs con tabla identifiers)
-- ============================================================

local RM = RaidMark
RM.Consumables = {}
local CS = RM.Consumables

-- ── Dimensiones (deben coincidir con mapframe.lua) ───────────────
local PANEL_W          = 312
local MAP_W            = 1365
local TOTAL_H          = 768 + 48 + 30
local TOOLBAR_H_LOCAL  = 48
local CS_W             = 650
local CS_H             = TOTAL_H - 30 - TOOLBAR_H_LOCAL

-- ── Verificacion de dependencia RABuffs ──────────────────────────
local function RABuffsAvailable()
    -- Solo necesitamos RAB_Buffs con su tabla de identifiers
    -- No usamos RAB_CallRaidBuffCheck (requiere campos bar.classes/label que no tenemos)
    return RAB_Buffs ~= nil
end

-- ── Tabla de consumibles ─────────────────────────────────────────
-- Cada entrada mapea nuestra key interna a la key exacta de RAB_Buffs.
-- name  = nombre que se muestra en la UI
-- rabKey = key en RAB_Buffs (nil si no existe en RABuffs)
-- group = grupo para agrupar en la tabla
-- roles = defaults de roles relevantes

CS.CONSUMABLE_LIST = {
    -- ── Flask ────────────────────────────────────────────────────
    { key="flask_sp",   rabKey="flask",         name="Flask Sup. Power",      group="Flask",      roles={TANK=false,HEAL=false,DPS_M=true, DPS_R=true}  },
    { key="flask_tit",  rabKey="titans",         name="Flask of the Titans",   group="Flask",      roles={TANK=true, HEAL=true, DPS_M=false,DPS_R=false} },
    { key="flask_wis",  rabKey="wisdom",         name="Flask Dist. Wisdom",    group="Flask",      roles={TANK=false,HEAL=true, DPS_M=false,DPS_R=true}  },
    { key="flask_chr",  rabKey="chromaticres",   name="Flask Chromatic Res.",  group="Flask",      roles={TANK=true, HEAL=true, DPS_M=true, DPS_R=true}  },
    -- ── Spell ────────────────────────────────────────────────────
    { key="gr_arcane",  rabKey="greaterarcane",  name="Greater Arcane Elixir", group="Spell",      roles={TANK=false,HEAL=false,DPS_M=true, DPS_R=true}  },
    { key="gr_fire",    rabKey="greaterfirepower",name="Elixir Gr. Firepower", group="Spell",      roles={TANK=false,HEAL=false,DPS_M=false,DPS_R=true}  },
    { key="shadow_pow", rabKey="shadowpower",    name="Elixir Shadow Power",   group="Spell",      roles={TANK=false,HEAL=false,DPS_M=true, DPS_R=true}  },
    { key="frost_pow",  rabKey="frostpower",     name="Elixir Frost Power",    group="Spell",      roles={TANK=false,HEAL=false,DPS_M=false,DPS_R=true}  },
    { key="cerebral",   rabKey="cerebralcortex", name="Cerebral Cortex Comp.", group="Spell",      roles={TANK=false,HEAL=false,DPS_M=true, DPS_R=true}  },
    -- ── Melee ────────────────────────────────────────────────────
    { key="mongoose",   rabKey="mongoose",       name="Elixir Mongoose",       group="Melee",      roles={TANK=true, HEAL=false,DPS_M=true, DPS_R=false} },
    { key="giants",     rabKey="giants",         name="Elixir of Giants",      group="Melee",      roles={TANK=true, HEAL=false,DPS_M=true, DPS_R=false} },
    { key="firewater",  rabKey="firewater",      name="Winterfall Firewater",  group="Melee",      roles={TANK=true, HEAL=false,DPS_M=true, DPS_R=false} },
    { key="juju_pow",   rabKey="jujupower",      name="Juju Power",            group="Melee",      roles={TANK=true, HEAL=false,DPS_M=true, DPS_R=false} },
    { key="juju_mgt",   rabKey="jujumight",      name="Juju Might",            group="Melee",      roles={TANK=true, HEAL=false,DPS_M=true, DPS_R=false} },
    { key="roids",      rabKey="roids",          name="R.O.I.D.S.",            group="Melee",      roles={TANK=false,HEAL=false,DPS_M=true, DPS_R=false} },
    { key="scorpok",    rabKey="scorpok",        name="Ground Scorpok Assay",  group="Melee",      roles={TANK=false,HEAL=false,DPS_M=true, DPS_R=false} },
    -- ── HP/Mana/Utility ──────────────────────────────────────────
    { key="mageblood",  rabKey="mageblood",      name="Mageblood Potion",      group="Utility",    roles={TANK=false,HEAL=true, DPS_M=false,DPS_R=true}  },
    { key="nightfin",   rabKey="nightfin",       name="Nightfin Soup",         group="Utility",    roles={TANK=false,HEAL=true, DPS_M=false,DPS_R=true}  },
    { key="stoneshld",  rabKey="stoneshield",    name="Gr. Stoneshield Pot.",  group="Utility",    roles={TANK=true, HEAL=false,DPS_M=false,DPS_R=false} },
    { key="sup_def",    rabKey="supdef",         name="Elixir Sup. Defense",   group="Utility",    roles={TANK=true, HEAL=false,DPS_M=false,DPS_R=false} },
    { key="sp_zanza",   rabKey="spiritofzanza",  name="Spirit of Zanza",       group="Utility",    roles={TANK=true, HEAL=true, DPS_M=true, DPS_R=true}  },
    { key="sh_zanza",   rabKey="sheenofzanza",   name="Sheen of Zanza",        group="Utility",    roles={TANK=false,HEAL=false,DPS_M=true, DPS_R=false} },
    -- ── Food/Drink ───────────────────────────────────────────────
    { key="dumpling",   rabKey="desertdumpling", name="Well Fed (STR)",        group="Food",       roles={TANK=true, HEAL=false,DPS_M=true, DPS_R=false} },
    { key="tuber",      rabKey="tuber",          name="Runn Tum Tuber",        group="Food",       roles={TANK=false,HEAL=true, DPS_M=false,DPS_R=true}  },
    { key="squid",      rabKey="squid",          name="Grilled Squid",         group="Food",       roles={TANK=false,HEAL=false,DPS_M=true, DPS_R=false} },
    -- ── Protection ───────────────────────────────────────────────
    { key="prot_fire",  rabKey="firepot",        name="Gr. Fire Protection",   group="Protection", roles={TANK=true, HEAL=true, DPS_M=true, DPS_R=true}  },
    { key="prot_arc",   rabKey="arcanepot",      name="Gr. Arcane Protection", group="Protection", roles={TANK=true, HEAL=true, DPS_M=true, DPS_R=true}  },
    { key="prot_nat",   rabKey="naturepot",      name="Gr. Nature Protection", group="Protection", roles={TANK=true, HEAL=true, DPS_M=true, DPS_R=true}  },
    { key="prot_sha",   rabKey="shadowpot",      name="Gr. Shadow Protection", group="Protection", roles={TANK=true, HEAL=true, DPS_M=true, DPS_R=true}  },
    { key="prot_fro",   rabKey="frostpot",       name="Gr. Frost Protection",  group="Protection", roles={TANK=true, HEAL=true, DPS_M=true, DPS_R=true}  },
    { key="prot_hol",   rabKey="holypot",        name="Gr. Holy Protection",   group="Protection", roles={TANK=true, HEAL=true, DPS_M=true, DPS_R=true}  },
    { key="froz_rune",  rabKey="frozenrune",     name="Frozen Rune",           group="Protection", roles={TANK=true, HEAL=true, DPS_M=true, DPS_R=true}  },
}

-- ── Keys de flask para Flask Checker ─────────────────────────────
CS.FLASK_KEYS = { "flask_sp", "flask_tit", "flask_wis", "flask_chr" }

-- ── Resistencias ─────────────────────────────────────────────────
CS.RESIST_DEFS = {
    { label="Fire",   r=1,   g=0.2, b=0.2, keys={"prot_fire","froz_rune"} },
    { label="Arcane", r=0.5, g=0.5, b=1,   keys={"prot_arc"} },
    { label="Nature", r=0.2, g=0.9, b=0.2, keys={"prot_nat"} },
    { label="Frost",  r=0.4, g=0.8, b=1,   keys={"prot_fro"} },
    { label="Shadow", r=0.7, g=0.3, b=0.9, keys={"prot_sha"} },
}

-- ── SavedVariables ───────────────────────────────────────────────
local function ensureDB()
    if not RaidMarkDB then RaidMarkDB = {} end
    if not RaidMarkDB.csWeights   then RaidMarkDB.csWeights   = {} end
    if not RaidMarkDB.csCrit      then RaidMarkDB.csCrit      = {} end
    if not RaidMarkDB.csRoles     then RaidMarkDB.csRoles     = {} end
    if not RaidMarkDB.csThreshold then
        RaidMarkDB.csThreshold = { TANK=5, HEAL=4, DPS_M=3, DPS_R=3 }
    end
    for _, c in ipairs(CS.CONSUMABLE_LIST) do
        if RaidMarkDB.csWeights[c.key] == nil then RaidMarkDB.csWeights[c.key] = 1 end
        if RaidMarkDB.csCrit[c.key]    == nil then RaidMarkDB.csCrit[c.key]    = false end
        if not RaidMarkDB.csRoles[c.key] then
            RaidMarkDB.csRoles[c.key] = {}
            for rk, rv in pairs(c.roles) do
                RaidMarkDB.csRoles[c.key][rk] = rv
            end
        end
    end
end

-- ── CORE: Scan via RABuffs ────────────────────────────────────────
-- scanResult[playerName][key] = true si el jugador tiene ese consumible
-- Copia exactamente la logica de ConsumesTracking / PollConsumes:
--   Para cada consumible, construye un bar={ buffKey=rabKey } y llama
--   RAB_CallRaidBuffCheck(bar, true, true) que devuelve raw={name,class,buffed}

CS.scanResult = {}
CS.scanCount  = 0
CS.scanTotal  = 0

-- ── Normalizar textura (extraer nombre base sin path ni extension) ──
local function normTex(btex)
    if not btex then return "" end
    local s = string.lower(btex)
    local lastSep = 0
    for pos = 1, string.len(s) do
        local ch = string.sub(s, pos, pos)
        if ch == "\\" or ch == "/" then lastSep = pos end
    end
    local base = string.sub(s, lastSep + 1)
    local dot = 0
    for pos = 1, string.len(base) do
        if string.sub(base, pos, pos) == "." then dot = pos end
    end
    if dot > 0 then base = string.sub(base, 1, dot - 1) end
    return base
end

-- ── Scan via RAB_Buffs.identifiers ───────────────────────────────
-- Usamos RAB_Buffs[rabKey].identifiers[i].texture directamente.
-- Esto evita RAB_CallRaidBuffCheck (que requiere bar.classes/label)
-- y usa los mismos datos que RABuffs tiene internamente.
-- UnitBuff en 1.12 devuelve la textura como primer valor.

local function doScan()
    ensureDB()
    CS.scanResult = {}
    CS.scanCount  = 0

    if not RABuffsAvailable() then return end

    local total = GetNumRaidMembers()
    CS.scanTotal = (total > 0) and total or 1

    -- Construir tabla de texturas para cada consumible usando RAB_Buffs.identifiers
    -- texTable[normTex] = { key1, key2, ... }  (una textura puede mapear a varias keys)
    local texTable = {}
    for _, c in ipairs(CS.CONSUMABLE_LIST) do
        local rabKey = c.rabKey
        if rabKey and RAB_Buffs and RAB_Buffs[rabKey] then
            local identifiers = RAB_Buffs[rabKey].identifiers
            if identifiers then
                for _, id in ipairs(identifiers) do
                    if id.texture and id.texture ~= "" then
                        local nt = normTex(id.texture)
                        if not texTable[nt] then texTable[nt] = {} end
                        -- Solo agregar si no esta ya en la lista
                        local already = false
                        for _, existing in ipairs(texTable[nt]) do
                            if existing == c.key then already = true; break end
                        end
                        if not already then
                            table.insert(texTable[nt], c.key)
                        end
                    end
                end
            end
        end
    end

    -- Escanear cada jugador
    local function scanUnit(unit, playerName)
        if not UnitExists(unit) then return end
        local i = 1
        while true do
            local btex = UnitBuff(unit, i)
            if not btex then break end
            local nt = normTex(btex)
            if texTable[nt] then
                for _, ckey in ipairs(texTable[nt]) do
                    CS.scanResult[playerName][ckey] = true
                end
            end
            i = i + 1
        end
    end

    if total > 0 then
        for i = 1, 40 do
            local name = GetRaidRosterInfo(i)
            if name and name ~= "" then
                CS.scanResult[name] = {}
                local unit = "raid"..i
                if UnitIsConnected(unit) then
                    scanUnit(unit, name)
                    CS.scanCount = CS.scanCount + 1
                end
            end
        end
    else
        local myName = UnitName("player")
        CS.scanResult[myName] = {}
        scanUnit("player", myName)
        CS.scanCount = 1
    end
end

-- ── Calculo de score ─────────────────────────────────────────────
local function calcScore(playerName, role)
    ensureDB()
    local found    = CS.scanResult[playerName] or {}
    local score    = 0
    local maxScore = 0
    for _, c in ipairs(CS.CONSUMABLE_LIST) do
        local w      = RaidMarkDB.csWeights[c.key] or 1
        local roles  = RaidMarkDB.csRoles[c.key]   or {}
        if roles[role] and w > 0 then
            maxScore = maxScore + w
            if found[c.key] then score = score + w end
        end
    end
    return score, maxScore
end

-- Consumibles que TIENE el jugador para su rol
local function playerConsumablesStr(playerName, role)
    ensureDB()
    local found = CS.scanResult[playerName] or {}
    local names = {}
    for _, c in ipairs(CS.CONSUMABLE_LIST) do
        local roles = RaidMarkDB.csRoles[c.key] or {}
        if roles[role] and found[c.key] then
            table.insert(names, c.name)
        end
    end
    if table.getn(names) == 0 then return "(ninguno)" end
    local s = ""
    for ii, n in ipairs(names) do
        if ii > 1 then s = s..", " end
        s = s..n
    end
    return s
end

-- Consumibles criticos que LE FALTAN al jugador para su rol
local function playerMissingCritStr(playerName, role)
    ensureDB()
    local found   = CS.scanResult[playerName] or {}
    local missing = {}
    for _, c in ipairs(CS.CONSUMABLE_LIST) do
        local roles = RaidMarkDB.csRoles[c.key] or {}
        if RaidMarkDB.csCrit[c.key] and roles[role] and not found[c.key] then
            table.insert(missing, c.name)
        end
    end
    if table.getn(missing) == 0 then return nil end
    local s = ""
    for ii, n in ipairs(missing) do
        if ii > 1 then s = s..", " end
        s = s..n
    end
    return s
end

-- ── Generacion de reportes ────────────────────────────────────────
local ROLE_ORDER = { "TANK", "HEAL", "DPS_M", "DPS_R" }
local ROLE_LABEL = { TANK="Tank", HEAL="Heal", DPS_M="DPS-M", DPS_R="DPS-R" }

-- buildReportLines(rwOnly):
--   rwOnly=true  -> compacto para /rw: header + por-rol jugadores bajo threshold
--   rwOnly=false -> completo para box: idem + seccion por rol con consumibles de todos
local function buildReportLines(rwOnly)
    ensureDB()
    local lines  = {}
    local noRole = {}

    for name, _ in pairs(CS.scanResult) do
        if not RM.state.memberRoles[name] then
            table.insert(noRole, name)
        end
    end

    -- Header siempre presente en ambos modos
    table.insert(lines, { text="[RaidMark] Scan "..CS.scanCount.."/"..CS.scanTotal
        .."  T="..(RaidMarkDB.csThreshold["TANK"] or 3)
        .." H="..(RaidMarkDB.csThreshold["HEAL"] or 3)
        .." DM="..(RaidMarkDB.csThreshold["DPS_M"] or 3)
        .." DR="..(RaidMarkDB.csThreshold["DPS_R"] or 3),
        r=0.7, g=0.75, b=0.5 })

    -- Bloque compacto: jugadores bajo threshold por rol
    local anyBelow = false
    for _, role in ipairs(ROLE_ORDER) do
        local thresh = RaidMarkDB.csThreshold[role] or 3
        local belowTxt = {}
        for name, _ in pairs(CS.scanResult) do
            if RM.state.memberRoles[name] == role then
                local score, maxScore = calcScore(name, role)
                if score < thresh then
                    table.insert(belowTxt, name.." "..score.."/"..maxScore)
                    anyBelow = true
                end
            end
        end
        if table.getn(belowTxt) > 0 then
            local txt = ROLE_LABEL[role].." [!]: "
            for ii, s in ipairs(belowTxt) do
                if ii > 1 then txt = txt.."  " end
                txt = txt..s
            end
            table.insert(lines, { text=txt, role=role, warn=true })
        end
    end
    if not anyBelow then
        table.insert(lines, { text="Todos sobre el threshold. OK.", r=0.3,g=1,b=0.4 })
    end

    if not rwOnly then
        -- Bloque extendido: consumibles por rol de TODOS los jugadores
        table.insert(lines, { text=" ", r=0.3,g=0.3,b=0.3 })
        for _, role in ipairs(ROLE_ORDER) do
            local playersOfRole = {}
            for name, _ in pairs(CS.scanResult) do
                if RM.state.memberRoles[name] == role then
                    table.insert(playersOfRole, name)
                end
            end
            if table.getn(playersOfRole) > 0 then
                table.insert(lines, { text=ROLE_LABEL[role]..":", role=role })
                for _, name in ipairs(playersOfRole) do
                    table.insert(lines, { text="  "..name..": "..playerConsumablesStr(name, role),
                        role=role, indent=true })
                end
            end
        end
    end

    if table.getn(noRole) > 0 then
        local ns = ""
        for ii, n in ipairs(noRole) do
            if ii > 1 then ns = ns..", " end
            ns = ns..n
        end
        table.insert(lines, { text=" ", r=0.3,g=0.3,b=0.3 })
        table.insert(lines, { text="Sin rol: "..ns, r=0.8,g=0.4,b=0.2 })
    end

    return lines
end

-- buildBasicLines: jugadores sin consumibles criticos marcados con !
local function buildBasicLines()
    ensureDB()
    local lines   = {}
    local noRole  = {}
    local missing = {}

    local hasCritDefined = false
    for _, c in ipairs(CS.CONSUMABLE_LIST) do
        if RaidMarkDB.csCrit[c.key] then hasCritDefined = true; break end
    end

    if not hasCritDefined then
        table.insert(lines, { text="[RaidMark] No hay consumibles marcados como criticos (!).", r=0.8,g=0.6,b=0.2 })
        table.insert(lines, { text="Marca consumibles con ! en Config.", r=0.6,g=0.5,b=0.3 })
        return lines
    end

    for name, found in pairs(CS.scanResult) do
        local role = RM.state.memberRoles[name]
        if not role then
            table.insert(noRole, name)
        else
            local hasCrit = true
            for _, c in ipairs(CS.CONSUMABLE_LIST) do
                local roles = RaidMarkDB.csRoles[c.key] or {}
                if RaidMarkDB.csCrit[c.key] and roles[role] and not found[c.key] then
                    hasCrit = false; break
                end
            end
            if not hasCrit then
                table.insert(missing, { name=name, role=role })
            end
        end
    end

    -- Header con scan info
    table.insert(lines, { text="[RaidMark] Scan "..CS.scanCount.."/"..CS.scanTotal.." - Sin consumibles criticos (!):",
        r=0.9, g=0.5, b=0.2 })

    if table.getn(missing) > 0 then
        for _, p in ipairs(missing) do
            local missCrit = playerMissingCritStr(p.name, p.role) or "(ver config)"
            local hasList  = playerConsumablesStr(p.name, p.role)
            table.insert(lines, { text=p.name.." le faltan: "..missCrit, r=1,g=0.3,b=0.3 })
            table.insert(lines, { text="  tiene: "..hasList, r=0.7,g=0.6,b=0.4 })
        end
    else
        table.insert(lines, { text="Todos con consumibles criticos. OK.", r=0.3,g=1,b=0.4 })
    end

    if table.getn(noRole) > 0 then
        local ns = ""
        for ii, n in ipairs(noRole) do
            if ii > 1 then ns = ns..", " end
            ns = ns..n
        end
        table.insert(lines, { text="Sin rol: "..ns, r=0.8,g=0.4,b=0.2 })
    end
    return lines
end

-- buildFlaskLines: verifica los 4 flasks principales
local function buildFlaskLines()
    local lines   = {}
    local ok_list = {}
    local miss    = {}
    for name, found in pairs(CS.scanResult) do
        local hasFlask = false
        for _, fk in ipairs(CS.FLASK_KEYS) do
            if found[fk] then hasFlask = true; break end
        end
        if hasFlask then table.insert(ok_list, name)
        else             table.insert(miss, name) end
    end
    table.insert(lines, { text="[Flask Checker] "..table.getn(ok_list).." con flask / "
        ..table.getn(miss).." sin flask", r=0.9,g=0.8,b=0.3 })
    if table.getn(miss) > 0 then
        local s = "Sin flask: "
        for ii, n in ipairs(miss) do
            if ii > 1 then s = s..", " end
            s = s..n
        end
        table.insert(lines, { text=s, r=1,g=0.3,b=0.3 })
    else
        table.insert(lines, { text="Todos con flask. OK.", r=0.3,g=1,b=0.4 })
    end
    return lines
end

-- buildResistLines: jugadores con/sin una resistencia especifica
local function buildResistLines(resistDef)
    local lines   = {}
    local ok_list = {}
    local miss    = {}
    for name, found in pairs(CS.scanResult) do
        local hasRes = false
        for _, rk in ipairs(resistDef.keys) do
            if found[rk] then hasRes = true; break end
        end
        if hasRes then table.insert(ok_list, name)
        else           table.insert(miss, name) end
    end
    table.insert(lines, { text="["..resistDef.label.." Resist] "..table.getn(ok_list)
        .." ok / "..table.getn(miss).." sin proteccion",
        r=resistDef.r, g=resistDef.g, b=resistDef.b })
    if table.getn(miss) > 0 then
        local s = "Sin "..resistDef.label..": "
        for ii, n in ipairs(miss) do
            if ii > 1 then s = s..", " end
            s = s..n
        end
        table.insert(lines, { text=s, r=1,g=0.3,b=0.3 })
    else
        table.insert(lines, { text="Todos con "..resistDef.label.." resist. OK.", r=0.3,g=1,b=0.4 })
    end
    return lines
end

-- ── Envio /rw con throttle 0.3s ──────────────────────────────────
local RW_MAX = 250

local function sendRWQueue(msgs)
    if not msgs or table.getn(msgs) == 0 then return end
    local idx = 1
    local elapsed = 0
    local rwFrame = CreateFrame("Frame", "RaidMarkRWQueue")
    rwFrame:SetScript("OnUpdate", function()
        elapsed = elapsed + arg1
        if elapsed >= 0.3 then
            elapsed = 0
            if idx <= table.getn(msgs) then
                SendChatMessage(msgs[idx], "RAID_WARNING")
                idx = idx + 1
            else
                rwFrame:SetScript("OnUpdate", nil)
            end
        end
    end)
end

local function chunkString(s)
    local chunks = {}
    while string.len(s) > RW_MAX do
        local cut = RW_MAX
        while cut > 1 and string.sub(s, cut, cut+1) ~= ", " do cut = cut - 1 end
        if cut <= 1 then cut = RW_MAX end
        table.insert(chunks, string.sub(s, 1, cut))
        s = string.sub(s, cut+1)
    end
    if string.len(s) > 0 then table.insert(chunks, s) end
    return chunks
end

local function buildRWMessages(lines)
    local msgs = {}
    for _, l in ipairs(lines) do
        local t = l.text
        if string.len(t) > RW_MAX then
            local chunks = chunkString(t)
            for _, ch in ipairs(chunks) do table.insert(msgs, ch) end
        else
            table.insert(msgs, t)
        end
    end
    return msgs
end

-- ── Ready Check Remoto ───────────────────────────────────────────
-- Protocolo:
--   Assist -> RL: "RC_REQ" via SendAddonMessage
--   RL ejecuta DoReadyCheck() y escucha READY_CHECK events
--   RL -> Assist: "RC_RESULT;nombre;estado" por cada respuesta
--   estado: "ready", "notready", "afk"
-- El box informativo muestra el resultado en tiempo real

CS.rcPending    = false   -- hay un RC en curso
CS.rcResults    = {}      -- { [nombre] = "ready"|"notready"|"afk" }
CS.rcTotal      = 0       -- total de raiders esperados
CS.rcRequester  = nil     -- nombre del assist que lo pidio (para RL)

local RC_DISPLAY_SECS = 15  -- tiempo que se muestra el resultado

local function rcDisplayResults()
    if not CS._setInfoBox then return end
    local notReady = {}
    local afk      = {}
    for name, state in pairs(CS.rcResults) do
        if state == "notready" then table.insert(notReady, name)
        elseif state == "afk"  then table.insert(afk, name) end
    end
    local lines = {}
    if table.getn(notReady) > 0 then
        local s = ""
        for ii, n in ipairs(notReady) do
            if ii > 1 then s = s..", " end; s = s..n
        end
        table.insert(lines, "No listos: "..s)
    end
    if table.getn(afk) > 0 then
        local s = ""
        for ii, n in ipairs(afk) do
            if ii > 1 then s = s..", " end; s = s..n
        end
        table.insert(lines, "AFK: "..s)
    end
    if table.getn(lines) == 0 then
        CS._setInfoBox("RC: Todos listos!", 0.3, 1, 0.4)
    else
        CS._setInfoBox("RC: "..table.concat(lines, " | "), 1, 0.5, 0.15)
    end
end

-- Envia solicitud de RC al RL (llamado por Assists y el propio RL)
function CS.SendReadyCheckRequest()
    local myName = UnitName("player")
    if RM.Permissions.IsRL() then
        -- El RL lo ejecuta directamente
        CS.rcResults = {}
        CS.rcTotal   = GetNumRaidMembers()
        CS.rcPending = true
        if CS._setInfoBox then CS._setInfoBox("RC enviado...", 0.9, 0.8, 0.2) end
        DoReadyCheck()
        return
    end
    if not (RM.Permissions.IsAssist() and RM.state.assistCanMove) then
        RM.Msg("Solo el RL o Assists autorizados pueden lanzar RC remoto.", 1, 0.3, 0.3)
        return
    end
    if GetNumRaidMembers() == 0 then
        RM.Msg("No estas en un raid.", 1, 0.4, 0.2)
        return
    end
    RM.Network.SendRaw("RC_REQ;"..myName)
    if CS._setInfoBox then CS._setInfoBox("RC solicitado al RL...", 0.8, 0.8, 0.3) end
end
CS.SendReadyCheckRequest = CS.SendReadyCheckRequest  -- expose global

-- Eventos de Ready Check: escuchar respuestas
local rcEventFrame = CreateFrame("Frame", "RaidMarkRCEventFrame")
rcEventFrame:RegisterEvent("READY_CHECK")
rcEventFrame:RegisterEvent("READY_CHECK_CONFIRM")
rcEventFrame:RegisterEvent("READY_CHECK_FINISHED")

rcEventFrame:SetScript("OnEvent", function()
    local ev = event
    if ev == "READY_CHECK" then
        -- Nuevo RC iniciado (alguien hizo DoReadyCheck)
        CS.rcResults = {}
        CS.rcTotal   = GetNumRaidMembers()
        CS.rcPending = true
        if CS._setInfoBox then CS._setInfoBox("RC en curso...", 0.9, 0.85, 0.3) end

    elseif ev == "READY_CHECK_CONFIRM" then
        -- arg1 = nombre del jugador, arg2 = 1 si ready, 0 si no
        local name  = arg1
        local ready = (arg2 == 1)
        if name and name ~= "" then
            CS.rcResults[name] = ready and "ready" or "notready"
            -- Si somos RL enviamos el resultado al assist que lo pidio
            if RM.Permissions.IsRL() and CS.rcRequester then
                local state = ready and "ready" or "notready"
                RM.Network.SendRaw("RC_RESULT;"..name..";"..state)
            end
            if CS.rcPending then rcDisplayResults() end
        end

    elseif ev == "READY_CHECK_FINISHED" then
        CS.rcPending = false
        -- Marcar AFK a los que no respondieron
        if GetNumRaidMembers() > 0 then
            for i = 1, 40 do
                local name = GetRaidRosterInfo(i)
                if name and name ~= "" and not CS.rcResults[name] then
                    CS.rcResults[name] = "afk"
                    if RM.Permissions.IsRL() and CS.rcRequester then
                        RM.Network.SendRaw("RC_RESULT;"..name..";afk")
                    end
                end
            end
        end
        rcDisplayResults()
        -- Auto-limpiar tras RC_DISPLAY_SECS
        local t = 0
        local clearFrame = CreateFrame("Frame", "RaidMarkRCClear")
        clearFrame:SetScript("OnUpdate", function()
            t = t + arg1
            if t >= RC_DISPLAY_SECS then
                if CS._setInfoBox then CS._setInfoBox("", 0.5, 0.5, 0.5) end
                clearFrame:SetScript("OnUpdate", nil)
            end
        end)
    end
end)

-- Procesar mensajes de red relacionados con RC
-- Llamado desde RM.Network.OnReceive en network.lua via hook
function CS.OnNetworkRC(cmd, parts, sender)
    if cmd == "RC_REQ" then
        -- Solo el RL reacciona a solicitudes de RC
        if not RM.Permissions.IsRL() then return end
        CS.rcRequester = parts[2] or sender
        CS.rcResults   = {}
        CS.rcTotal     = GetNumRaidMembers()
        CS.rcPending   = true
        DoReadyCheck()
        RM.Msg("RC solicitado por "..tostring(CS.rcRequester), 0.9, 0.85, 0.3)

    elseif cmd == "RC_RESULT" then
        -- El assist recibe resultados del RL
        if RM.Permissions.IsRL() then return end  -- el RL ya los tiene localmente
        local name  = parts[2]
        local state = parts[3]
        if name and state then
            CS.rcResults[name] = state
            rcDisplayResults()
        end
    end
end

-- ── UI ───────────────────────────────────────────────────────────
local csPanel      = nil   -- frame principal del panel
local csToggleBtn  = nil   -- boton < en borde de sidePanel
local csVisible    = false
local csMode       = "config"  -- "config" o "reporte"
local csReportLines = {}       -- ultimas lineas calculadas para el box
local csResistDD   = nil       -- dropdown de resistencias
local csResistOpen = false
local csActiveResist = nil     -- indice en CS.RESIST_DEFS seleccionado

-- Referencias a widgets que necesitan actualizarse
local csBoxLines   = {}   -- FontStrings del box informativo
local csBoxScroll  = nil
local csBoxContent = nil
local csRowFrames  = {}   -- { [key] = { weightDD, critChk, roleChks } }
local csScanLabel  = nil
CS._activeResistCallerBtn = nil  -- boton que abrio el dropdown de resistencias

local function canUse()
    return RM.Permissions.IsRL() or
           (RM.Permissions.IsAssist() and RM.state.assistCanMove)
end

-- Actualiza el label de scan
local function updateScanLabel()
    if csScanLabel then
        csScanLabel:SetText("Scan: "..CS.scanCount.."/"..CS.scanTotal)
    end
end

-- Dibuja las lineas en el box informativo con scroll
local function refreshBox(lines)
    csReportLines = lines
    if not csBoxContent then return end

    -- Limpiar FontStrings anteriores
    for _, fs in ipairs(csBoxLines) do
        fs:SetText("")
    end

    local LINE_H = 16
    local yOff = 0
    local needed = table.getn(lines)

    -- Crear FontStrings adicionales si hacen falta
    while table.getn(csBoxLines) < needed do
        local fs = csBoxContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetWidth(CS_W - 20)
        fs:SetJustifyH("LEFT")
        fs:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
        table.insert(csBoxLines, fs)
    end

    for i, l in ipairs(lines) do
        local fs = csBoxLines[i]
        fs:ClearAllPoints()
        fs:SetPoint("TOPLEFT", csBoxContent, "TOPLEFT", 4, -yOff)
        fs:SetText(l.text)
        if l.indent then
            fs:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
        else
            fs:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
        end
        if l.r then
            fs:SetTextColor(l.r, l.g or 0.8, l.b or 0.5, 1)
        elseif l.warn then
            -- bajo threshold: siempre rojo/naranja segun rol
            if l.role == "TANK"  then fs:SetTextColor(1,0.4,0.4,1)
            elseif l.role == "HEAL"  then fs:SetTextColor(1,0.5,0.3,1)
            elseif l.role == "DPS_M" then fs:SetTextColor(1,0.3,0.1,1)
            elseif l.role == "DPS_R" then fs:SetTextColor(1,0.5,0.0,1)
            else fs:SetTextColor(1,0.4,0.3,1) end
        else
            -- color normal por rol
            if l.role == "TANK"  then fs:SetTextColor(0.3,0.6,1,1)
            elseif l.role == "HEAL"  then fs:SetTextColor(0.3,1,0.4,1)
            elseif l.role == "DPS_M" then fs:SetTextColor(1,0.2,0.2,1)
            elseif l.role == "DPS_R" then fs:SetTextColor(1,0.55,0.05,1)
            else fs:SetTextColor(0.8,0.8,0.6,1) end
        end
        yOff = yOff + LINE_H
    end

    csBoxContent:SetHeight(math.max(1, yOff))
    if csBoxScroll then
        csBoxScroll:SetVerticalScroll(0)
    end
end

-- Alterna entre modo config y reporte
local function setMode(mode, configArea, reportArea, configTab, reportTab)
    csMode = mode
    if mode == "config" then
        configArea:Show()
        reportArea:Hide()
        configTab:SetBackdropBorderColor(0.8,0.65,0.1,1)
        configTab.labelText:SetTextColor(1,0.9,0.3,1)
        reportTab:SetBackdropBorderColor(0.5,0.42,0.22,0.9)
        reportTab.labelText:SetTextColor(0.7,0.7,0.7,1)
    else
        configArea:Hide()
        reportArea:Show()
        reportTab:SetBackdropBorderColor(0.8,0.65,0.1,1)
        reportTab.labelText:SetTextColor(1,0.9,0.3,1)
        configTab:SetBackdropBorderColor(0.5,0.42,0.22,0.9)
        configTab.labelText:SetTextColor(0.7,0.7,0.7,1)
    end
end

-- ── Constructor principal ─────────────────────────────────────────
function CS.Build(mainFrame, sidePanel)
    ensureDB()

    -- Declaraciones anticipadas
    local configArea = nil
    local reportArea = nil
    local configTab  = nil
    local reportTab  = nil

    -- ── Verificar RABuffs antes de construir la UI completa ───────
    local rabOK = RABuffsAvailable()

    local SIDE_H = CS_H  -- TOTAL_H - 30

    -- ── Panel principal ──────────────────────────────────────────
    csPanel = CreateFrame("Frame", "RaidMarkCSPanel", mainFrame)
    csPanel:SetWidth(CS_W)
    csPanel:SetHeight(SIDE_H)
    -- Anclado al borde IZQUIERDO del sidePanel, se extiende hacia la izquierda
    csPanel:SetPoint("TOPRIGHT", sidePanel, "TOPLEFT", 0, -TOOLBAR_H_LOCAL)
    csPanel:SetFrameStrata("DIALOG")
    csPanel:SetFrameLevel(20)
    csPanel:Hide()

    local bg = csPanel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(csPanel)
    bg:SetTexture(0.05, 0.05, 0.08, 0.97)

    -- Overlay transparente sobre el lienzo para bloquear clicks cuando el panel esta abierto
    local canvasBlock = CreateFrame("Frame", "RaidMarkCSCanvasBlock", mainFrame)
    canvasBlock:SetFrameStrata("DIALOG")
    canvasBlock:SetFrameLevel(19)  -- justo debajo del panel (nivel 20)
    canvasBlock:SetWidth(MAP_W)
    canvasBlock:SetHeight(CS_H)
    canvasBlock:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, -(30 + TOOLBAR_H_LOCAL))
    canvasBlock:EnableMouse(true)   -- absorbe todos los clicks
    canvasBlock:Hide()

    local border = CreateFrame("Frame", nil, csPanel)
    border:SetFrameStrata("DIALOG")
    border:SetFrameLevel(21)
    border:SetAllPoints(csPanel)
    border:SetBackdrop({
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize=10,
        insets={left=3,right=3,top=3,bottom=3}
    })
    border:SetBackdropBorderColor(0.4,0.35,0.2,1)

    -- ── Boton toggle < en borde izquierdo de sidePanel ───────────
    csToggleBtn = CreateFrame("Button", "RaidMarkCSToggle", mainFrame)
    csToggleBtn:SetWidth(16)
    csToggleBtn:SetHeight(60)
    csToggleBtn:SetFrameStrata("DIALOG")
    csToggleBtn:SetFrameLevel(25)
    -- Centrado verticalmente en sidePanel
    csToggleBtn:SetPoint("TOPRIGHT", sidePanel, "TOPLEFT", 0, -(SIDE_H - 200))

    csToggleBtn:SetBackdrop({
        bgFile="Interface\\Buttons\\WHITE8X8",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize=6,
        insets={left=1,right=1,top=1,bottom=1}
    })
    csToggleBtn:SetBackdropColor(0.10,0.09,0.05,0.95)
    csToggleBtn:SetBackdropBorderColor(0.6,0.5,0.2,1)

    local toggleTxt = csToggleBtn:CreateFontString(nil,"OVERLAY","GameFontNormal")
    toggleTxt:SetAllPoints(csToggleBtn)
    toggleTxt:SetText("<")
    toggleTxt:SetTextColor(0.9,0.75,0.2,1)
    toggleTxt:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")

    csToggleBtn:SetScript("OnClick", function()
        csVisible = not csVisible
        if csVisible then
            csPanel:Show()
            canvasBlock:Show()
            toggleTxt:SetText(">")
        else
            csPanel:Hide()
            canvasBlock:Hide()
            toggleTxt:SetText("<")
            if csResistDD then csResistDD:Hide() end
        end
    end)
    csToggleBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(csToggleBtn,"ANCHOR_LEFT")
        GameTooltip:SetText("Panel de Consumibles")
        GameTooltip:AddLine("Click para abrir/cerrar",0.7,0.7,0.7,true)
        GameTooltip:Show()
    end)
    csToggleBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- ── Helper: boton de toolbar ──────────────────────────────────
    local function makeBtn(lbl, w, parent)
        local b = CreateFrame("Button", nil, parent or csPanel)
        b:SetWidth(w); b:SetHeight(22)
        b:SetBackdrop({
            bgFile="Interface\\Buttons\\WHITE8X8",
            edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize=6,
            insets={left=2,right=2,top=2,bottom=2}
        })
        b:SetBackdropColor(0.10,0.09,0.05,0.95)
        b:SetBackdropBorderColor(0.5,0.42,0.22,0.9)
        local fs = b:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
        fs:SetAllPoints(b)
        fs:SetText(lbl)
        fs:SetTextColor(0.85,0.75,0.4,1)
        fs:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
        b.labelText = fs
        b:SetScript("OnEnter", function()
            b:SetBackdropBorderColor(0.8,0.7,0.3,1)
        end)
        b:SetScript("OnLeave", function()
            b:SetBackdropBorderColor(0.5,0.42,0.22,0.9)
        end)
        return b
    end

    -- ── Title bar ────────────────────────────────────────────────
    local titleH = 24
    local titleBar = CreateFrame("Frame", nil, csPanel)
    titleBar:SetHeight(titleH)
    titleBar:SetWidth(CS_W)
    titleBar:SetPoint("TOPLEFT", csPanel, "TOPLEFT", 0, 0)
    local titleBg = titleBar:CreateTexture(nil,"BACKGROUND")
    titleBg:SetAllPoints(titleBar)
    titleBg:SetTexture(0.10,0.08,0.04,1)
    local titleTxt = titleBar:CreateFontString(nil,"OVERLAY","GameFontNormal")
    titleTxt:SetPoint("LEFT",titleBar,"LEFT",8,0)
    titleTxt:SetText("Consumibles de Raid")
    titleTxt:SetTextColor(0.7,0.85,1,1)
    titleTxt:SetFont("Fonts\\FRIZQT__.TTF",13,"")

    local scanBtn = makeBtn("Scan Raid", 70, titleBar)
    scanBtn:SetPoint("RIGHT", titleBar, "RIGHT", -8, 0)

    csScanLabel = titleBar:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    csScanLabel:SetPoint("RIGHT",scanBtn,"LEFT",-6,0)
    csScanLabel:SetText("Scan: 0/0")
    csScanLabel:SetTextColor(0.5,0.7,0.5,1)
    csScanLabel:SetFont("Fonts\\FRIZQT__.TTF",9,"")
    scanBtn.labelText:SetTextColor(0.4,0.8,1,1)
    scanBtn:SetScript("OnClick", function()
        if not RABuffsAvailable() then
            refreshBox({ { text="RABuffs no encontrado. Instala RABuffs para usar este modulo.", r=1,g=0.4,b=0.2 } })
            return
        end
        doScan()
        updateScanLabel()
        if CS._updateNoRoleLabels then CS._updateNoRoleLabels() end
        if csMode == "reporte" then
            refreshBox(buildReportLines(false))
        end
    end)

    -- ── Tabs Config / Reporte ─────────────────────────────────────
    local tabY = -(titleH + 2)
    local tabH = 22

    configTab = makeBtn("Config", 80)
    configTab:SetPoint("TOPLEFT", csPanel, "TOPLEFT", 4, tabY)

    reportTab = makeBtn("Reporte", 80)
    reportTab:SetPoint("TOPLEFT", csPanel, "TOPLEFT", 88, tabY)

    -- ── Botones RW (siempre visibles en tab row) ─────────────────
    local rwCompleto = makeBtn("/rw Completo", 100)
    rwCompleto:SetPoint("TOPRIGHT", csPanel, "TOPRIGHT", -4, tabY)
    rwCompleto.labelText:SetTextColor(1,0.8,0.1,1)
    rwCompleto:SetBackdropBorderColor(0.7,0.5,0.1,1)

    local rwBasicos = makeBtn("/rw Basicos", 90)
    rwBasicos:SetPoint("TOPRIGHT", rwCompleto, "TOPLEFT", -4, 0)
    rwBasicos.labelText:SetTextColor(0.3,0.9,0.4,1)
    rwBasicos:SetBackdropBorderColor(0.2,0.5,0.2,1)

    -- ── Area Config ──────────────────────────────────────────────
    local areaY = tabY - tabH - 2
    local sideW = 145   -- ancho del sidebar derecho dentro del panel
    local tableW = CS_W - sideW - 6

    configArea = CreateFrame("Frame", nil, csPanel)
    configArea:SetPoint("TOPLEFT", csPanel, "TOPLEFT", 0, areaY)
    configArea:SetPoint("BOTTOMRIGHT", csPanel, "BOTTOMRIGHT", 0, 0)

    -- ── Tabla de consumibles ─────────────────────────────────────
    local COL_PESO = 32   -- peso sigue existiendo, mismo ancho
    local COL_CRIT = 20   -- columna !
    local COL_SEP  = 6    -- separador visual entre ! y roles
    local COL_ROL  = 26   -- columna de rol
    local tableInner = tableW - COL_PESO - COL_CRIT - COL_SEP - COL_ROL*4 - 8

    -- Header de tabla
    local hdrH = 16
    local hdr = CreateFrame("Frame", nil, configArea)
    hdr:SetHeight(hdrH); hdr:SetWidth(tableW)
    hdr:SetPoint("TOPLEFT", configArea, "TOPLEFT", 2, 0)
    local hdrBg = hdr:CreateTexture(nil,"BACKGROUND")
    hdrBg:SetAllPoints(hdr); hdrBg:SetTexture(0.10,0.09,0.05,1)

    local function hdrLabel(txt, x, w, r, g, b)
        local f = hdr:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
        f:SetWidth(w); f:SetHeight(hdrH)
        f:SetPoint("LEFT",hdr,"LEFT",x,0)
        f:SetText(txt)
        f:SetJustifyH("CENTER")
        f:SetFont("Fonts\\FRIZQT__.TTF",10,"")
        f:SetTextColor(r or 0.75,g or 0.65,b or 0.3,1)
    end
    hdrLabel("Consumible", 4, tableInner, 0.8,0.7,0.3)
    local hx = tableInner + 4
    hdrLabel("Peso", hx, COL_PESO, 0.7,0.7,0.5); hx = hx + COL_PESO
    hdrLabel("!", hx, COL_CRIT, 1,0.8,0.1); hx = hx + COL_CRIT
    -- Separador visual header
    local hdrSep = hdr:CreateTexture(nil,"ARTWORK")
    hdrSep:SetWidth(1); hdrSep:SetHeight(hdrH - 4)
    hdrSep:SetPoint("LEFT",hdr,"LEFT",hx + COL_SEP/2,0)
    hdrSep:SetTexture(0.6,0.5,0.2,0.7)
    hx = hx + COL_SEP
    hdrLabel("H",  hx, COL_ROL, 0.3,1,0.4); hx = hx + COL_ROL
    hdrLabel("DM", hx, COL_ROL, 1,0.2,0.2); hx = hx + COL_ROL
    hdrLabel("DR", hx, COL_ROL, 1,0.55,0.05); hx = hx + COL_ROL
    hdrLabel("T",  hx, COL_ROL, 0.3,0.6,1)

    -- ScrollFrame para la tabla
    local TABLE_SCROLL_H = math.max(80, SIDE_H - math.abs(areaY) - hdrH - 4)

    -- Scroll invisible: sin barra visible, solo rueda del mouse
    local tableScroll = CreateFrame("ScrollFrame","RaidMarkCSTableScroll",configArea)
    tableScroll:SetWidth(tableW - 2)
    tableScroll:SetHeight(TABLE_SCROLL_H)
    tableScroll:SetPoint("TOPLEFT", configArea, "TOPLEFT", 2, -hdrH)
    tableScroll:EnableMouseWheel(true)
    tableScroll:SetScript("OnMouseWheel", function()
        local delta = arg1
        local cur = tableScroll:GetVerticalScroll()
        local mx = tableScroll:GetVerticalScrollRange()
        local nv = cur - delta * 21 * 3
        if nv < 0 then nv = 0 end
        if nv > mx then nv = mx end
        tableScroll:SetVerticalScroll(nv)
    end)

    local tableContent = CreateFrame("Frame", nil, tableScroll)
    tableContent:SetWidth(tableW - 4)
    tableContent:SetHeight(1)
    tableScroll:SetScrollChild(tableContent)

    -- Construir filas de consumibles
    local ROW_H = 21
    local groups = {}
    local groupOrder = {}
    for _, c in ipairs(CS.CONSUMABLE_LIST) do
        if not groups[c.group] then
            groups[c.group] = {}
            table.insert(groupOrder, c.group)
        end
        table.insert(groups[c.group], c)
    end

    local yOff = 0
    csRowFrames = {}

    -- Helper: checkbox cuadrado 
    local function makeCheck(parent, isOn)
        local f = CreateFrame("Button", nil, parent)
        f:SetWidth(11); f:SetHeight(11)
        f:SetBackdrop({
            bgFile="Interface\\Buttons\\WHITE8X8",
            edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize=4,
            insets={left=1,right=1,top=1,bottom=1}
        })
        f.checked = isOn or false
        local function refresh()
            if f.checked then
                f:SetBackdropColor(0.8,0.65,0.1,1)
                f:SetBackdropBorderColor(1,0.85,0.2,1)
            else
                f:SetBackdropColor(0.05,0.05,0.07,1)
                f:SetBackdropBorderColor(0.4,0.35,0.2,0.8)
            end
        end
        refresh()
        f:SetScript("OnClick", function()
            f.checked = not f.checked
            refresh()
            if f.onChange then f.onChange(f.checked) end
        end)
        return f
    end

    for _, grp in ipairs(groupOrder) do
        -- Label de grupo
        local glbl = tableContent:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
        glbl:SetWidth(tableW - 22)
        glbl:SetHeight(14)
        glbl:SetPoint("TOPLEFT", tableContent, "TOPLEFT", 0, -yOff)
        glbl:SetText("-- "..grp.." --")
        glbl:SetJustifyH("LEFT")
        glbl:SetFont("Fonts\\FRIZQT__.TTF",10,"")
        glbl:SetTextColor(0.6,0.5,0.25,1)
        local glblBg = tableContent:CreateTexture(nil,"BACKGROUND")
        glblBg:SetHeight(14); glblBg:SetWidth(tableW-22)
        glblBg:SetPoint("TOPLEFT", tableContent,"TOPLEFT",0,-yOff)
        glblBg:SetTexture(0.08,0.07,0.04,1)
        yOff = yOff + 14

        for _, c in ipairs(groups[grp]) do
            -- fila con fondo alternado
            local rowBg = tableContent:CreateTexture(nil,"BACKGROUND")
            rowBg:SetHeight(ROW_H); rowBg:SetWidth(tableW-22)
            rowBg:SetPoint("TOPLEFT",tableContent,"TOPLEFT",0,-yOff)
            if math.mod(yOff, ROW_H*2) < ROW_H then
                rowBg:SetTexture(0.07,0.07,0.09,1)
            else
                rowBg:SetTexture(0.04,0.04,0.06,1)
            end

            -- Nombre
            local nameLbl = tableContent:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
            nameLbl:SetWidth(tableInner)
            nameLbl:SetHeight(ROW_H)
            nameLbl:SetPoint("TOPLEFT",tableContent,"TOPLEFT",2,-yOff)
            nameLbl:SetText(c.name)
            nameLbl:SetJustifyH("LEFT")
            nameLbl:SetFont("Fonts\\FRIZQT__.TTF",11,"")
            nameLbl:SetTextColor(0.85,0.80,0.65,1)

            local rx = tableInner + 4

            -- Peso (dropdown 0-5)
            local pesoDD = CreateFrame("Button",nil,tableContent)
            pesoDD:SetWidth(COL_PESO-2); pesoDD:SetHeight(ROW_H-2)
            pesoDD:SetPoint("TOPLEFT",tableContent,"TOPLEFT",rx,-(yOff + 1))
            pesoDD:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",
                edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize=4,insets={left=1,right=1,top=1,bottom=1}})
            pesoDD:SetBackdropColor(0.05,0.05,0.08,1)
            pesoDD:SetBackdropBorderColor(0.4,0.35,0.2,0.8)
            local pesoLbl = pesoDD:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
            pesoLbl:SetAllPoints(pesoDD)
            local wVal = RaidMarkDB.csWeights[c.key] or 1
            pesoLbl:SetText(tostring(wVal).." v")
            pesoLbl:SetFont("Fonts\\FRIZQT__.TTF",10,"")
            pesoLbl:SetTextColor(0.9,0.85,0.4,1)
            pesoLbl:SetJustifyH("CENTER")
            pesoDD.labelText = pesoLbl
            pesoDD.ckey = c.key

            -- Dropdown popup de peso
            local weightPopup = CreateFrame("Frame","RaidMarkWP_"..c.key,UIParent)
            weightPopup:SetWidth(30); weightPopup:SetHeight(6*16+8)
            weightPopup:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",
                edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize=6,insets={left=2,right=2,top=2,bottom=2}})
            weightPopup:SetBackdropColor(0.05,0.05,0.08,1)
            weightPopup:SetBackdropBorderColor(0.5,0.4,0.2,1)
            weightPopup:SetFrameStrata("FULLSCREEN_DIALOG")
            weightPopup:SetFrameLevel(200)
            weightPopup:Hide()

            for v = 0, 5 do
                local vbtn = CreateFrame("Button",nil,weightPopup)
                vbtn:SetWidth(26); vbtn:SetHeight(14)
                vbtn:SetPoint("TOPLEFT",weightPopup,"TOPLEFT",2,-(4+(5-v)*15))
                local vfs = vbtn:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
                vfs:SetAllPoints(vbtn); vfs:SetText(tostring(v))
                vfs:SetFont("Fonts\\FRIZQT__.TTF",9,"")
                vfs:SetTextColor(0.9,0.85,0.5,1)
                local vval = v
                local vbtnDD = pesoDD
                local vbtnPopup = weightPopup
                vbtn:SetScript("OnClick", function()
                    RaidMarkDB.csWeights[vbtnDD.ckey] = vval
                    vbtnDD.labelText:SetText(tostring(vval).." v")
                    vbtnPopup:Hide()
                end)
                vbtn:SetScript("OnEnter", function()
                    vfs:SetTextColor(1,1,0.5,1)
                end)
                vbtn:SetScript("OnLeave", function()
                    vfs:SetTextColor(0.9,0.85,0.5,1)
                end)
            end

            pesoDD:SetScript("OnClick", function()
                -- Cerrar otros popups
                if RaidMarkActiveWeightPopup and RaidMarkActiveWeightPopup ~= weightPopup then
                    RaidMarkActiveWeightPopup:Hide()
                end
                if weightPopup:IsVisible() then
                    weightPopup:Hide()
                    RaidMarkActiveWeightPopup = nil
                else
                    weightPopup:ClearAllPoints()
                    weightPopup:SetPoint("BOTTOMLEFT",pesoDD,"TOPLEFT",0,2)
                    weightPopup:Show()
                    RaidMarkActiveWeightPopup = weightPopup
                end
            end)

            rx = rx + COL_PESO

            -- Critico (check) - columna !
            local critChk = makeCheck(tableContent, RaidMarkDB.csCrit[c.key] or false)
            critChk:SetPoint("TOPLEFT",tableContent,"TOPLEFT",rx + 4,-(yOff + 5))
            local ck = c.key
            critChk.onChange = function(val)
                RaidMarkDB.csCrit[ck] = val
            end
            rx = rx + COL_CRIT

            -- Separador visual entre ! y roles (linea vertical)
            local rowSep = tableContent:CreateTexture(nil,"ARTWORK")
            rowSep:SetWidth(1); rowSep:SetHeight(ROW_H - 2)
            rowSep:SetPoint("TOPLEFT",tableContent,"TOPLEFT",rx + COL_SEP/2,-(yOff + 1))
            rowSep:SetTexture(0.5,0.4,0.15,0.5)
            rx = rx + COL_SEP

            -- Checks de rol: nuevo orden H DM DR T
            local roleKeys = {"HEAL","DPS_M","DPS_R","TANK"}
            local roleChks = {}
            if not RaidMarkDB.csRoles[c.key] then
                RaidMarkDB.csRoles[c.key] = {}
                for rk, rv in pairs(c.roles) do
                    RaidMarkDB.csRoles[c.key][rk] = rv
                end
            end
            for ri, rk in ipairs(roleKeys) do
                local rChk = makeCheck(tableContent, RaidMarkDB.csRoles[c.key][rk] or false)
                rChk:SetPoint("TOPLEFT",tableContent,"TOPLEFT",rx + 7,-(yOff + 5))
                local ck2 = c.key
                local rk2 = rk
                rChk.onChange = function(val)
                    RaidMarkDB.csRoles[ck2][rk2] = val
                end
                table.insert(roleChks, rChk)
                rx = rx + COL_ROL
            end

            csRowFrames[c.key] = { pesoDD=pesoDD, critChk=critChk, roleChks=roleChks }
            yOff = yOff + ROW_H
        end
    end

    tableContent:SetHeight(math.max(1, yOff))

    -- ── Sidebar derecho (dentro de configArea) ────────────────────
    local sidebarX = tableW + 4
    local sidebarY = 0

    -- Helper label de seccion
    local function sideLabel(txt, y)
        local f = configArea:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
        f:SetWidth(sideW - 4)
        f:SetPoint("TOPLEFT",configArea,"TOPLEFT",sidebarX + 2, y)
        f:SetText(txt)
        f:SetFont("Fonts\\FRIZQT__.TTF",10,"")
        f:SetTextColor(0.7,0.6,0.25,1)
        f:SetJustifyH("LEFT")
        return f
    end

    -- Threshold minimo
    local thY = sidebarY
    sideLabel("Threshold minimo:", thY); thY = thY - 12

    local threshDefs = {
        { role="TANK",  label="Tank",  r=0.3,g=0.6,b=1   },
        { role="HEAL",  label="Heal",  r=0.3,g=1,  b=0.4  },
        { role="DPS_M", label="DPS M", r=1,  g=0.2,b=0.2  },
        { role="DPS_R", label="DPS R", r=1,  g=0.55,b=0.05 },
    }
    for _, td in ipairs(threshDefs) do
        local rowF = CreateFrame("Frame",nil,configArea)
        rowF:SetWidth(sideW-4); rowF:SetHeight(16)
        rowF:SetPoint("TOPLEFT",configArea,"TOPLEFT",sidebarX+2,thY)

        local lbl = rowF:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
        lbl:SetWidth(36); lbl:SetHeight(16)
        lbl:SetPoint("LEFT",rowF,"LEFT",0,0)
        lbl:SetText(td.label)
        lbl:SetFont("Fonts\\FRIZQT__.TTF",10,"")
        lbl:SetTextColor(td.r,td.g,td.b,1)
        lbl:SetJustifyH("LEFT")

        local eb = CreateFrame("EditBox",nil,rowF)
        eb:SetWidth(28); eb:SetHeight(14)
        eb:SetPoint("LEFT",rowF,"LEFT",38,0)
        eb:SetFont("Fonts\\FRIZQT__.TTF",10,"")
        eb:SetTextColor(0.9,0.85,0.5,1)
        eb:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",
            edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize=4,insets={left=1,right=1,top=1,bottom=1}})
        eb:SetBackdropColor(0.04,0.04,0.06,1)
        eb:SetBackdropBorderColor(0.4,0.35,0.2,0.8)
        eb:SetAutoFocus(false)
        eb:SetMaxLetters(2)
        eb:SetText(tostring(RaidMarkDB.csThreshold[td.role] or 3))
        local role = td.role
        eb:SetScript("OnEnterPressed", function()
            local v = tonumber(eb:GetText()) or 3
            if v < 0 then v=0 end
            if v > 99 then v=99 end
            RaidMarkDB.csThreshold[role] = v
            eb:ClearFocus()
        end)
        eb:SetScript("OnEscapePressed", function() eb:ClearFocus() end)

        thY = thY - 17
    end

    thY = thY - 6

    -- Box de informacion: sin rol / ready check feedback
    thY = thY - 8
    sideLabel("Info:", thY); thY = thY - 14

    -- ScrollFrame invisible para la lista de sin-rol
    local noRoleScroll = CreateFrame("ScrollFrame", nil, configArea)
    noRoleScroll:SetWidth(sideW - 8)
    noRoleScroll:SetHeight(72)
    noRoleScroll:SetPoint("TOPLEFT", configArea, "TOPLEFT", sidebarX + 2, thY)
    noRoleScroll:EnableMouseWheel(true)
    local noRoleInner = CreateFrame("Frame", nil, noRoleScroll)
    noRoleInner:SetWidth(sideW - 10)
    noRoleInner:SetHeight(200)  -- height for up to ~40 names
    noRoleScroll:SetScrollChild(noRoleInner)
    noRoleScroll:SetScript("OnMouseWheel", function()
        local delta = arg1
        local cur = noRoleScroll:GetVerticalScroll()
        local mx = noRoleScroll:GetVerticalScrollRange()
        local nv = cur - delta * 12 * 2
        if nv < 0 then nv = 0 end
        if nv > mx then nv = mx end
        noRoleScroll:SetVerticalScroll(nv)
    end)
    -- Fondo sutil del box
    local noRoleBg = configArea:CreateTexture(nil, "BACKGROUND")
    noRoleBg:SetWidth(sideW - 8)
    noRoleBg:SetHeight(72)
    noRoleBg:SetPoint("TOPLEFT", configArea, "TOPLEFT", sidebarX + 2, thY)
    noRoleBg:SetTexture(0.06, 0.04, 0.04, 0.8)

    local noRoleLbl = noRoleInner:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    noRoleLbl:SetWidth(sideW - 12)
    noRoleLbl:SetPoint("TOPLEFT", noRoleInner, "TOPLEFT", 2, 0)
    noRoleLbl:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
    noRoleLbl:SetTextColor(0.85, 0.35, 0.2, 1)
    noRoleLbl:SetJustifyH("LEFT")
    noRoleLbl:SetText("(sin scan)")

    thY = thY - 80

    -- Acciones simples - Flask Checker y Resistencias mas abajo

    -- Acciones simples
    sideLabel("Acciones simples:", thY); thY = thY - 14

    -- Flask Checker
    local flaskBtn = makeBtn("Flask Checker", sideW-8, configArea)
    flaskBtn:SetPoint("TOPLEFT",configArea,"TOPLEFT",sidebarX+2,thY)
    flaskBtn.labelText:SetTextColor(0.4,0.7,1,1)
    flaskBtn:SetBackdropBorderColor(0.2,0.4,0.7,1)
    flaskBtn:SetScript("OnClick", function()
        if not canUse() then RM.Msg("Solo RL/Assist.",1,0.3,0.3); return end
        if CS.scanCount == 0 then doScan(); updateScanLabel() end
        local lines = buildFlaskLines()
        refreshBox(lines)
        setMode("reporte", configArea, reportArea, configTab, reportTab)
        -- Flask Checker envia directo a /rw (es un check rapido puntual)
        local msgs = buildRWMessages(lines)
        sendRWQueue(msgs)
    end)
    thY = thY - 26

    -- Resistencias + dropdown
    local resistBtnW = sideW - 24
    local resistBtn = makeBtn("Resistencias", resistBtnW, configArea)
    resistBtn:SetPoint("TOPLEFT",configArea,"TOPLEFT",sidebarX+2,thY)
    resistBtn.labelText:SetTextColor(0.7,0.7,0.7,1)

    local resistArrow = makeBtn("v", 18, configArea)
    resistArrow:SetPoint("TOPLEFT",configArea,"TOPLEFT",sidebarX+2+resistBtnW+2,thY)
    resistArrow.labelText:SetFont("Fonts\\FRIZQT__.TTF",8,"")

    -- Dropdown de resistencias
    csResistDD = CreateFrame("Frame","RaidMarkCSResistDD",UIParent)
    csResistDD:SetWidth(90); csResistDD:SetHeight(table.getn(CS.RESIST_DEFS) * 18 + 8)
    csResistDD:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize=6,insets={left=2,right=2,top=2,bottom=2}})
    csResistDD:SetBackdropColor(0.04,0.04,0.06,1)
    csResistDD:SetBackdropBorderColor(0.5,0.4,0.2,1)
    csResistDD:SetFrameStrata("FULLSCREEN_DIALOG")
    csResistDD:SetFrameLevel(200)
    csResistDD:Hide()

    for ri, rd in ipairs(CS.RESIST_DEFS) do
        local rbtn = CreateFrame("Button",nil,csResistDD)
        rbtn:SetWidth(86); rbtn:SetHeight(16)
        rbtn:SetPoint("TOPLEFT",csResistDD,"TOPLEFT",2,-(4+(ri-1)*17))
        local rfs = rbtn:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
        rfs:SetAllPoints(rbtn); rfs:SetText(rd.label)
        rfs:SetFont("Fonts\\FRIZQT__.TTF",9,"")
        rfs:SetTextColor(rd.r,rd.g,rd.b,1)
        rfs:SetJustifyH("LEFT")
        local rdi = ri
        local rdDef = rd
        rbtn:SetScript("OnClick", function()
            csActiveResist = rdi
            csResistDD:Hide()
            -- Colorear el boton que abrio el dropdown (config o reporte)
            local targetBtn = CS._activeResistCallerBtn or resistBtn
            targetBtn.labelText:SetTextColor(rdDef.r,rdDef.g,rdDef.b,1)
            targetBtn.labelText:SetText("Res: "..rdDef.label)
            targetBtn:SetBackdropBorderColor(rdDef.r*0.7,rdDef.g*0.7,rdDef.b*0.7,1)
            -- Sincronizar ambos botones
            if CS._activeResistCallerBtn and CS._activeResistCallerBtn ~= resistBtn then
                resistBtn.labelText:SetTextColor(rdDef.r,rdDef.g,rdDef.b,1)
                resistBtn.labelText:SetText("Res: "..rdDef.label)
                resistBtn:SetBackdropBorderColor(rdDef.r*0.7,rdDef.g*0.7,rdDef.b*0.7,1)
            end
            CS._activeResistCallerBtn = nil
        end)
        rbtn:SetScript("OnEnter",function() rfs:SetTextColor(1,1,1,1) end)
        rbtn:SetScript("OnLeave",function() rfs:SetTextColor(rdDef.r,rdDef.g,rdDef.b,1) end)
    end

    resistArrow:SetScript("OnClick", function()
        if csResistDD:IsVisible() then
            csResistDD:Hide()
            CS._activeResistCallerBtn = nil
        else
            CS._activeResistCallerBtn = resistBtn  -- marcar que abrio desde config
            csResistDD:ClearAllPoints()
            csResistDD:SetPoint("TOPLEFT",resistArrow,"BOTTOMLEFT",0,-2)
            csResistDD:Show()
        end
    end)

    resistBtn:SetScript("OnClick", function()
        if not canUse() then RM.Msg("Solo RL/Assist.",1,0.3,0.3); return end
        if not csActiveResist then
            RM.Msg("Selecciona un tipo de resistencia primero (v).",1,0.7,0.2)
            return
        end
        if CS.scanCount == 0 then doScan(); updateScanLabel() end
        local rd = CS.RESIST_DEFS[csActiveResist]
        local lines = buildResistLines(rd)
        refreshBox(lines)
        setMode("reporte", configArea, reportArea, configTab, reportTab)
        -- Resistencias envia directo a /rw (check puntual rapido)
        local msgs = buildRWMessages(lines)
        sendRWQueue(msgs)
    end)

    thY = thY - 26

    thY = thY - 8

    -- Ready Check Remoto (config sidebar)
    local rcBtn = makeBtn("RC Remoto", sideW-8, configArea)
    rcBtn:SetPoint("TOPLEFT",configArea,"TOPLEFT",sidebarX+2,thY)
    rcBtn.labelText:SetTextColor(0.9,0.75,0.15,1)
    rcBtn:SetBackdropBorderColor(0.6,0.5,0.1,1)
    rcBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(rcBtn,"ANCHOR_LEFT")
        GameTooltip:SetText("Ready Check Remoto")
        GameTooltip:AddLine("Asistente envia RC al RL para que lo ejecute.",0.7,0.7,0.7,true)
        GameTooltip:AddLine("RL necesita RaidMark instalado.",0.5,0.5,0.5,true)
        GameTooltip:Show()
    end)
    rcBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    rcBtn:SetScript("OnClick", function()
        CS.SendReadyCheckRequest()
    end)


    -- ── Area Reporte ─────────────────────────────────────────────
    reportArea = CreateFrame("Frame",nil,csPanel)
    reportArea:SetPoint("TOPLEFT",csPanel,"TOPLEFT",0,areaY)
    reportArea:SetPoint("BOTTOMRIGHT",csPanel,"BOTTOMRIGHT",0,0)
    reportArea:Hide()

    -- Ancho del sidebar de reporte (igual que config)
    local rSideW = sideW
    local boxW = CS_W - rSideW - 10

    -- Box de reporte: scroll invisible, ocupa lado izquierdo
    local boxPad = 4
    csBoxScroll = CreateFrame("ScrollFrame","RaidMarkCSBoxScroll",reportArea)
    csBoxScroll:SetPoint("TOPLEFT",reportArea,"TOPLEFT",boxPad,-boxPad)
    csBoxScroll:SetPoint("BOTTOMRIGHT",reportArea,"BOTTOMRIGHT",rSideW + 6, boxPad)
    csBoxScroll:EnableMouseWheel(true)
    csBoxScroll:SetScript("OnMouseWheel",function()
        local delta = arg1
        local cur = csBoxScroll:GetVerticalScroll()
        local mx = csBoxScroll:GetVerticalScrollRange()
        local nv = cur - delta*16*3
        if nv < 0 then nv=0 end
        if nv > mx then nv=mx end
        csBoxScroll:SetVerticalScroll(nv)
    end)

    csBoxContent = CreateFrame("Frame",nil,csBoxScroll)
    csBoxContent:SetWidth(boxW - 8)
    csBoxContent:SetHeight(1)
    csBoxScroll:SetScrollChild(csBoxContent)

    -- Separador vertical entre box y sidebar
    local rSep = reportArea:CreateTexture(nil,"ARTWORK")
    rSep:SetWidth(1); rSep:SetPoint("TOPRIGHT",reportArea,"TOPRIGHT",-(rSideW+4),0)
    rSep:SetPoint("BOTTOMRIGHT",reportArea,"BOTTOMRIGHT",-(rSideW+4),0)
    rSep:SetTexture(0.4,0.35,0.2,0.6)

    -- Sidebar derecho del reporte: Sin rol + Acciones simples
    local rSideX = CS_W - rSideW - 4
    local rThY = -4

    -- Helper label de seccion para reporte sidebar
    local function rSideLabel(txt, y)
        local f = reportArea:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
        f:SetWidth(rSideW - 4)
        f:SetPoint("TOPLEFT",reportArea,"TOPLEFT",rSideX + 2, y)
        f:SetText(txt)
        f:SetFont("Fonts\\FRIZQT__.TTF",10,"")
        f:SetTextColor(0.7,0.6,0.25,1)
        f:SetJustifyH("LEFT")
        return f
    end

    -- Box de informacion compartido (reporte)
    rSideLabel("Info:", rThY); rThY = rThY - 14
    local rNoRoleScroll = CreateFrame("ScrollFrame",nil,reportArea)
    rNoRoleScroll:SetWidth(rSideW - 8)
    rNoRoleScroll:SetHeight(72)
    rNoRoleScroll:SetPoint("TOPLEFT",reportArea,"TOPLEFT",rSideX + 2, rThY)
    rNoRoleScroll:EnableMouseWheel(true)
    local rNoRoleInner = CreateFrame("Frame",nil,rNoRoleScroll)
    rNoRoleInner:SetWidth(rSideW - 10); rNoRoleInner:SetHeight(200)
    rNoRoleScroll:SetScrollChild(rNoRoleInner)
    rNoRoleScroll:SetScript("OnMouseWheel",function()
        local delta = arg1
        local cur = rNoRoleScroll:GetVerticalScroll()
        local mx = rNoRoleScroll:GetVerticalScrollRange()
        local nv = cur - delta*12*2
        if nv < 0 then nv=0 end
        if nv > mx then nv=mx end
        rNoRoleScroll:SetVerticalScroll(nv)
    end)
    local rNoRoleBg = reportArea:CreateTexture(nil,"BACKGROUND")
    rNoRoleBg:SetWidth(rSideW-8); rNoRoleBg:SetHeight(72)
    rNoRoleBg:SetPoint("TOPLEFT",reportArea,"TOPLEFT",rSideX+2,rThY)
    rNoRoleBg:SetTexture(0.06,0.04,0.04,0.8)
    local rNoRoleLbl = rNoRoleInner:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    rNoRoleLbl:SetWidth(rSideW-12)
    rNoRoleLbl:SetPoint("TOPLEFT",rNoRoleInner,"TOPLEFT",2,0)
    rNoRoleLbl:SetFont("Fonts\\FRIZQT__.TTF",10,"")
    rNoRoleLbl:SetTextColor(0.85,0.35,0.2,1)
    rNoRoleLbl:SetJustifyH("LEFT")
    rNoRoleLbl:SetText("(sin scan)")
    rThY = rThY - 80

    -- Acciones simples (reporte sidebar)
    rSideLabel("Acciones simples:", rThY); rThY = rThY - 14

    local rFlaskBtn = makeBtn("Flask Checker", rSideW-8, reportArea)
    rFlaskBtn:SetPoint("TOPLEFT",reportArea,"TOPLEFT",rSideX+2,rThY)
    rFlaskBtn.labelText:SetTextColor(0.4,0.7,1,1)
    rFlaskBtn:SetBackdropBorderColor(0.2,0.4,0.7,1)
    rFlaskBtn:SetScript("OnClick", function()
        if not canUse() then RM.Msg("Solo RL/Assist.",1,0.3,0.3); return end
        if CS.scanCount == 0 then doScan(); updateScanLabel() end
        local lines = buildFlaskLines()
        refreshBox(lines)
        local msgs = buildRWMessages(lines)
        sendRWQueue(msgs)
    end)
    rThY = rThY - 26

    local rResistBtnW = rSideW - 24
    local rResistBtn = makeBtn("Resistencias", rResistBtnW, reportArea)
    rResistBtn:SetPoint("TOPLEFT",reportArea,"TOPLEFT",rSideX+2,rThY)
    rResistBtn.labelText:SetTextColor(0.7,0.7,0.7,1)

    local rResistArrow = makeBtn("v", 18, reportArea)
    rResistArrow:SetPoint("TOPLEFT",reportArea,"TOPLEFT",rSideX+2+rResistBtnW+2,rThY)
    rResistArrow.labelText:SetFont("Fonts\\FRIZQT__.TTF",8,"")

    -- Dropdown de resistencias del reporte (reutiliza csResistDD y csActiveResist)
    rResistArrow:SetScript("OnClick", function()
        if csResistDD:IsVisible() then
            csResistDD:Hide()
            CS._activeResistCallerBtn = nil
        else
            CS._activeResistCallerBtn = rResistBtn  -- marcar que abrio desde reporte
            csResistDD:ClearAllPoints()
            csResistDD:SetPoint("TOPLEFT",rResistArrow,"BOTTOMLEFT",0,-2)
            csResistDD:Show()
        end
    end)
    rResistBtn:SetScript("OnClick", function()
        if not canUse() then RM.Msg("Solo RL/Assist.",1,0.3,0.3); return end
        if not csActiveResist then
            RM.Msg("Selecciona tipo de resistencia (v).",1,0.7,0.2); return
        end
        if CS.scanCount == 0 then doScan(); updateScanLabel() end
        local rd = CS.RESIST_DEFS[csActiveResist]
        local lines = buildResistLines(rd)
        refreshBox(lines)
        local msgs = buildRWMessages(lines)
        sendRWQueue(msgs)
        -- Sync color with selected resistance
        rResistBtn.labelText:SetText("Res: "..rd.label)
        rResistBtn.labelText:SetTextColor(rd.r,rd.g,rd.b,1)
        rResistBtn:SetBackdropBorderColor(rd.r*0.7,rd.g*0.7,rd.b*0.7,1)
    end)
    rThY = rThY - 34

    -- Ready Check Remoto (reporte sidebar)
    local rRcBtn = makeBtn("RC Remoto", rSideW-8, reportArea)
    rRcBtn:SetPoint("TOPLEFT",reportArea,"TOPLEFT",rSideX+2,rThY)
    rRcBtn.labelText:SetTextColor(0.9,0.75,0.15,1)
    rRcBtn:SetBackdropBorderColor(0.6,0.5,0.1,1)
    rRcBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(rRcBtn,"ANCHOR_LEFT")
        GameTooltip:SetText("Ready Check Remoto")
        GameTooltip:AddLine("Asistente envia RC al RL para que lo ejecute.",0.7,0.7,0.7,true)
        GameTooltip:AddLine("RL necesita RaidMark instalado.",0.5,0.5,0.5,true)
        GameTooltip:Show()
    end)
    rRcBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    rRcBtn:SetScript("OnClick", function()
        CS.SendReadyCheckRequest()
    end)
    rThY = rThY - 26

    -- ── Sistema de box informativo compartido ─────────────────────
    -- El box muestra: sin rol / resultados de ready check / vacio si todo ok
    -- Se auto-limpia despues de un tiempo cuando muestra "sin rol"

    local infoBoxTimer = nil

    local function setInfoBox(txt, r, g, b)
        if noRoleLbl then
            noRoleLbl:SetText(txt or "")
            noRoleLbl:SetTextColor(r or 0.8, g or 0.7, b or 0.4, 1)
        end
        if rNoRoleLbl then
            rNoRoleLbl:SetText(txt or "")
            rNoRoleLbl:SetTextColor(r or 0.8, g or 0.7, b or 0.4, 1)
        end
    end
    CS._setInfoBox = setInfoBox

    -- Mostrar sin rol durante 8 segundos, luego limpiar el box
    local function updateNoRoleLabels()
        local noRoleNow = {}
        for name, _ in pairs(RM.Roster.members) do
            if not RM.state.memberRoles[name] then
                table.insert(noRoleNow, name)
            end
        end
        if table.getn(noRoleNow) > 0 then
            local s = ""
            for ii, n in ipairs(noRoleNow) do
                if ii > 1 then s = s..", " end
                s = s..n
            end
            setInfoBox("Sin rol: "..s, 0.85, 0.4, 0.15)
            -- Auto-limpiar el box luego de 8s
            if infoBoxTimer then infoBoxTimer:SetScript("OnUpdate", nil) end
            infoBoxTimer = CreateFrame("Frame", "RaidMarkInfoBoxTimer")
            local elapsed = 0
            infoBoxTimer:SetScript("OnUpdate", function()
                elapsed = elapsed + arg1
                if elapsed >= 8 then
                    setInfoBox("", 0.5, 0.5, 0.5)
                    infoBoxTimer:SetScript("OnUpdate", nil)
                end
            end)
        else
            -- Sin jugadores sin rol: limpiar silenciosamente
            setInfoBox("", 0.5, 0.5, 0.5)
        end
    end
    CS._updateNoRoleLabels = updateNoRoleLabels

    -- ── Scripts de tabs ──────────────────────────────────────────
    configTab:SetScript("OnClick", function()
        setMode("config", configArea, reportArea, configTab, reportTab)
    end)
    reportTab:SetScript("OnClick", function()
        if not RABuffsAvailable() then
            setMode("reporte", configArea, reportArea, configTab, reportTab)
            refreshBox({ { text="RABuffs no encontrado. Instala RABuffs para usar este modulo.", r=1,g=0.4,b=0.2 },
                         { text="Sin RABuffs, el panel de consumibles no puede funcionar.", r=0.7,g=0.5,b=0.2 } })
            return
        end
        if CS.scanCount == 0 then doScan(); updateScanLabel() end
        if CS._updateNoRoleLabels then CS._updateNoRoleLabels() end
        local lines = buildReportLines(false)
        refreshBox(lines)
        setMode("reporte", configArea, reportArea, configTab, reportTab)
    end)

    -- ── Scripts de RW ────────────────────────────────────────────
    -- Sistema de doble-click para /rw:
    -- 1er click: muestra resultado en box + cambia a Reporte, boton amarillo
    -- 2do click (< 3s): envia al canal /rw, boton vuelve normal
    -- sin 2do click: timeout 3s, boton vuelve normal
    local rwCompletoArmed   = false
    local rwCompletoTimer   = 0
    local rwBasicosArmed    = false
    local rwBasicosTimer    = 0
    local rwTimerFrame = CreateFrame("Frame", "RaidMarkRWTimer")

    local function resetRwCompleto()
        rwCompletoArmed = false
        rwCompletoTimer = 0
        rwCompleto.labelText:SetText("/rw Completo")
        rwCompleto:SetBackdropBorderColor(0.7,0.5,0.1,1)
        rwCompleto.labelText:SetTextColor(1,0.8,0.1,1)
    end
    local function resetRwBasicos()
        rwBasicosArmed = false
        rwBasicosTimer = 0
        rwBasicos.labelText:SetText("/rw Basicos")
        rwBasicos:SetBackdropBorderColor(0.2,0.5,0.2,1)
        rwBasicos.labelText:SetTextColor(0.3,0.9,0.4,1)
    end

    rwTimerFrame:SetScript("OnUpdate", function()
        local dt = arg1
        if rwCompletoArmed then
            rwCompletoTimer = rwCompletoTimer + dt
            -- Contar regresiva en el boton
            local remaining = math.floor(3 - rwCompletoTimer + 1)
            if remaining < 1 then remaining = 1 end
            rwCompleto.labelText:SetText("/rw Completo ("..remaining.."s)")
            if rwCompletoTimer >= 3 then
                resetRwCompleto()
            end
        end
        if rwBasicosArmed then
            rwBasicosTimer = rwBasicosTimer + dt
            local remaining = math.floor(3 - rwBasicosTimer + 1)
            if remaining < 1 then remaining = 1 end
            rwBasicos.labelText:SetText("/rw Basicos ("..remaining.."s)")
            if rwBasicosTimer >= 3 then
                resetRwBasicos()
            end
        end
        if not rwCompletoArmed and not rwBasicosArmed then
            rwTimerFrame:SetScript("OnUpdate", nil)
        end
    end)

    local function startRwTimer()
        rwTimerFrame:SetScript("OnUpdate", function()
            local dt = arg1
            if rwCompletoArmed then
                rwCompletoTimer = rwCompletoTimer + dt
                local remaining = math.max(1, math.floor(3 - rwCompletoTimer + 1))
                rwCompleto.labelText:SetText("/rw Completo ("..remaining.."s)")
                if rwCompletoTimer >= 3 then resetRwCompleto() end
            end
            if rwBasicosArmed then
                rwBasicosTimer = rwBasicosTimer + dt
                local remaining = math.max(1, math.floor(3 - rwBasicosTimer + 1))
                rwBasicos.labelText:SetText("/rw Basicos ("..remaining.."s)")
                if rwBasicosTimer >= 3 then resetRwBasicos() end
            end
            if not rwCompletoArmed and not rwBasicosArmed then
                rwTimerFrame:SetScript("OnUpdate", nil)
            end
        end)
    end

    rwCompleto:SetScript("OnClick", function()
        if not canUse() then RM.Msg("Solo RL/Assist.",1,0.3,0.3); return end
        if rwCompletoArmed then
            -- Segundo click: enviar al canal
            if CS.scanCount == 0 then doScan(); updateScanLabel() end
            local lines = buildReportLines(true)  -- rwOnly=true
            local msgs = buildRWMessages(lines)
            sendRWQueue(msgs)
            resetRwCompleto()
        else
            -- Primer click: mostrar en box y armar
            resetRwBasicos()
            if CS.scanCount == 0 then doScan(); updateScanLabel() end
            local lines = buildReportLines(false)
            refreshBox(lines)
            setMode("reporte", configArea, reportArea, configTab, reportTab)
            -- Armar boton
            rwCompletoArmed = true
            rwCompletoTimer = 0
            rwCompleto.labelText:SetText("/rw Completo (3s)")
            rwCompleto:SetBackdropBorderColor(1,0.9,0.1,1)
            rwCompleto.labelText:SetTextColor(1,1,0.2,1)
            startRwTimer()
        end
    end)

    rwBasicos:SetScript("OnClick", function()
        if not canUse() then RM.Msg("Solo RL/Assist.",1,0.3,0.3); return end
        if rwBasicosArmed then
            -- Segundo click: enviar al canal
            if CS.scanCount == 0 then doScan(); updateScanLabel() end
            local lines = buildBasicLines()
            local msgs = buildRWMessages(lines)
            sendRWQueue(msgs)
            resetRwBasicos()
        else
            -- Primer click: mostrar en box y armar
            resetRwCompleto()
            if CS.scanCount == 0 then doScan(); updateScanLabel() end
            local lines = buildBasicLines()
            refreshBox(lines)
            setMode("reporte", configArea, reportArea, configTab, reportTab)
            -- Armar boton
            rwBasicosArmed = true
            rwBasicosTimer = 0
            rwBasicos.labelText:SetText("/rw Basicos (3s)")
            rwBasicos:SetBackdropBorderColor(0.9,0.8,0.1,1)
            rwBasicos.labelText:SetTextColor(1,0.95,0.2,1)
            startRwTimer()
        end
    end)

    -- Inicializar segun disponibilidad de RABuffs
    if not rabOK then
        if configArea then configArea:Hide() end
        if configTab then
            configTab:SetBackdropColor(0.05,0.04,0.02,0.7)
            configTab.labelText:SetTextColor(0.35,0.28,0.18,1)
            configTab:EnableMouse(false)
        end
        setMode("reporte", configArea, reportArea, configTab, reportTab)
        refreshBox({
            { text="RABuffs no esta instalado o no esta cargado.", r=1,g=0.4,b=0.2 },
            { text=" ", r=0.3,g=0.3,b=0.3 },
            { text="El panel de consumibles requiere RABuffs para funcionar.", r=0.8,g=0.7,b=0.4 },
            { text="Instala RABuffs y escribe /reload para activar este modulo.", r=0.6,g=0.8,b=0.6 },
        })
    else
        setMode("reporte", configArea, reportArea, configTab, reportTab)
    end

    -- Actualizar label sin rol al abrir
    csPanel:SetScript("OnShow", function()
        ensureDB()
        if CS._updateNoRoleLabels then CS._updateNoRoleLabels() end
        if RaidMarkActiveWeightPopup then
            RaidMarkActiveWeightPopup:Hide()
            RaidMarkActiveWeightPopup = nil
        end
        -- Re-verificar RABuffs cada vez que se abre
        if not RABuffsAvailable() then
            if configArea then configArea:Hide() end
            refreshBox({
                { text="RABuffs no esta instalado o no esta cargado.", r=1,g=0.4,b=0.2 },
                { text="Instala RABuffs y escribe /reload para activar este modulo.", r=0.6,g=0.8,b=0.6 },
            })
        end
    end)

    -- Ocultar popups al cerrar
    csPanel:SetScript("OnHide", function()
        if RaidMarkActiveWeightPopup then
            RaidMarkActiveWeightPopup:Hide()
            RaidMarkActiveWeightPopup = nil
        end
        if csResistDD then csResistDD:Hide() end
    end)
end
