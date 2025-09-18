local ESX = exports['es_extended']:getSharedObject()
local hasInitialized = false

CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Wait(100)
    end
    
    exports.ox_inventory:displayMetadata('plate', 'Plaque')
    exports.ox_inventory:displayMetadata('model', 'Modèle')
    
    exports.ox_target:addGlobalVehicle({
        {
            name = 'quantom_keys:toggle_lock',
            icon = 'fas fa-key',
            label = 'Verrouiller/Déverrouiller',
            canInteract = function(entity, distance, coords, name, bone)
                return distance <= Config.LockDistance
            end,
            onSelect = function(data)
                QK.ToggleVehicleLock(data.entity)
            end
        }
    })
    
    exports('vehicle_key', function(data, slot)
        local metadata = slot.metadata
        if metadata and metadata.plate then
            local vehicle = QK.GetVehicleByPlate(metadata.plate)
            if vehicle then
                QK.ToggleVehicleLock(vehicle)
            else
                QK.Notification('Véhicule non trouvé à proximité', 'error')
            end
        end
    end)
    
    RegisterNetEvent('quantom_keys:receiveKey')
    AddEventHandler('quantom_keys:receiveKey', function(plate, model)
        QK.Notification(Config.Locales['key_received'], 'success')
    end)
    
    RegisterNetEvent('esx:enteredVehicle')
    AddEventHandler('esx:enteredVehicle', function(vehicle, plate, seat)
        if seat == -1 then
            local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
            local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
            
            ESX.TriggerServerCallback('quantom_keys:checkVehicleOwnership', function(hasKey, isOwner)
                if isOwner and not hasKey then
                    TriggerServerEvent('quantom_keys:createKey', plate, model)
                end
            end, plate)
        end
    end)
    
    hasInitialized = true
end)

RegisterNetEvent('quantom_keys:toggleLock')
AddEventHandler('quantom_keys:toggleLock', function()
    local vehicle, distance = QK.GetClosestVehicle()
    
    if vehicle and distance <= Config.LockDistance then
        QK.ToggleVehicleLock(vehicle)
    else
        QK.Notification(Config.Locales['no_vehicle'], 'error')
    end
end)

exports('toggleLock', function(vehicle)
    QK.ToggleVehicleLock(vehicle)
end)

exports('hasKey', function(plate, cb)
    ESX.TriggerServerCallback('quantom_keys:checkHasKey', function(hasKey)
        if cb then cb(hasKey) end
    end, plate)
end)

AddEventHandler('gameEventTriggered', function(name, args)
    if name == 'CEventNetworkVehicleUndrivable' then
        local vehicle, attacker = args[1], args[2]
        if DoesEntityExist(vehicle) and not IsPedAPlayer(attacker) then
            if GetVehicleDoorLockStatus(vehicle) == 2 then
                SetVehicleDoorsLocked(vehicle, 1)
            end
        end
    end
end)