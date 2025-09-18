local ESX = exports['es_extended']:getSharedObject()

CreateThread(function()
    while not _G.QK do 
        Wait(100)
    end
    
    if Config.UseKeybind then
        -- Utilisation de RegisterKeyMapping pour une meilleure gestion des touches
        RegisterKeyMapping('quantom_keys_toggle', 'Verrouiller/déverrouiller le véhicule', 'keyboard', 'U')
        
        -- Enregistrement de la commande qui sera liée à la touche
        RegisterCommand('quantom_keys_toggle', function()
            TriggerEvent('quantom_keys:toggleLock')
        end, false)
        
        -- Pour la compatibilité avec ox_lib, on garde aussi cette méthode
        lib.addKeybind({
            name = 'quantom_keys_toggle',
            description = 'Verrouiller/déverrouiller le véhicule le plus proche',
            defaultKey = Config.KeybindKey,
            onPressed = function()
                TriggerEvent('quantom_keys:toggleLock')
            end
        })
    end
end)