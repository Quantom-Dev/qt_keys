Config = {}

Config.NotificationSystem = 'ox'
Config.UseTarget = true

-- Configuration du verrouillage
Config.UseKeybind = true
Config.KeybindKey = 303 -- Touche U pour verrouiller/déverrouiller
Config.LockDistance = 10.0 -- Distance maximale pour verrouiller un véhicule

-- Configuration de l'animation
Config.UseAnimation = true
Config.AnimationDict = 'anim@mp_player_intmenu@key_fob@'
Config.AnimationName = 'fob_click'
Config.AnimationDuration = 800

-- Configuration des sons et effets
Config.LockSound = 'Remote_Control_Close'
Config.UnlockSound = 'Remote_Control_Open'
Config.FlashLights = true
Config.FlashCount = 2

Config.MenuSettings = {
    UseKeyBinding = true,
    UseInteractionPoint = false,
    InteractionKey = 38,
    KeyBinding = 167,
    InteractionPoint = {
        coords = vector3(-31.53, -1113.31, 26.42),
        radius = 1.5,
        marker = {
            enabled = true,
            type = 1,
            size = vector3(1.0, 1.0, 1.0),
            color = {r = 0, g = 100, b = 255, a = 100},
            bobUpAndDown = false,
            rotate = false
        },
        blip = {
            enabled = true,
            sprite = 523,
            color = 3,
            scale = 0.8,
            label = "Gestion des clés"
        }
    }
}

Config.Items = {
    KeyItem = 'vehicle_key'
}

Config.Locales = {
    ['not_cardealer'] = "Vous n'êtes pas un concessionnaire",
    ['key_created'] = "Clé créée avec succès",
    ['key_received'] = "Vous avez reçu une clé pour le véhicule %s",
    ['key_given'] = "Vous avez donné une clé pour le véhicule %s",
    ['no_vehicle_found'] = "Aucun véhicule trouvé avec cette plaque",
    ['press_e_interact'] = "Appuyez sur ~INPUT_CONTEXT~ pour accéder à la gestion des clés",
    ['vehicle_locked'] = "Véhicule verrouillé",
    ['vehicle_unlocked'] = "Véhicule déverrouillé",
    ['not_owner'] = "Vous n'avez pas les clés de ce véhicule",
    ['no_vehicle'] = "Aucun véhicule à proximité"
}