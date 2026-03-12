-- maps.lua
-- TexCoords para mostrar cada mapa sin distorsion

RaidMark_Maps = {
    ["twin_emperors"] = {
        file  = "Interface\\AddOns\\RaidMark\\maps\\map_twin_emperors.tga",
        label = "Twin Emperors",
        u2    = 1.0,
        v2    = 1.0,
    },
    ["cthun_normal"] = {
        file  = "Interface\\AddOns\\RaidMark\\maps\\map_cthun_normal.tga",
        label = "C'Thun - Exterior",
        u2    = 1.0,
        v2    = 1.0,
    },
    ["cthun_stomach"] = {
        file  = "Interface\\AddOns\\RaidMark\\maps\\map_cthun_stomach.tga",
        label = "C'Thun - Estomago",
        u2    = 1.0,
        v2    = 1.0,
    },
    ["skeram"] = {
        file  = "Interface\\AddOns\\RaidMark\\maps\\map_skeram.tga",
        label = "El Profeta Skeram",
        u2    = 1.0,
        v2    = 1.0,
    },
    ["ouro"] = {
        file  = "Interface\\AddOns\\RaidMark\\maps\\map_ouro.tga",
        label = "Ouro",
        u2    = 1.0,
        v2    = 1.0,
    },
    ["huhuran"] = {
        file  = "Interface\\AddOns\\RaidMark\\maps\\map_huhuran.tga",
        label = "Huhuran la Princesa",
        u2    = 1.0,
        v2    = 1.0,
    },
    ["viscidus"] = {
        file  = "Interface\\AddOns\\RaidMark\\maps\\map_viscidus.tga",
        label = "Viscidus",
        u2    = 1.0,
        v2    = 1.0,
    },
    ["fankriss"] = {
        file  = "Interface\\AddOns\\RaidMark\\maps\\map_fankriss.tga",
        label = "Fankriss el Inquebrantable",
        u2    = 1.0,
        v2    = 1.0,
    },
    ["sartura"] = {
        file  = "Interface\\AddOns\\RaidMark\\maps\\map_sartura.tga",
        label = "Sartura - Guardia Real",
        u2    = 1.0,
        v2    = 1.0,
    },
    ["bugstrio"] = {
        file  = "Interface\\AddOns\\RaidMark\\maps\\map_bugstrio.tga",
        label = "El Trio de Bichos",
        u2    = 1.0,
        v2    = 1.0,
    },
}

-- Debug: confirmar que maps.lua cargo
DEFAULT_CHAT_FRAME:AddMessage("RaidMark: maps.lua cargado OK - " .. tostring(RaidMark_Maps))
