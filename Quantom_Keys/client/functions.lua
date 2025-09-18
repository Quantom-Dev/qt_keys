local QK = {}
local ESX = exports['es_extended']:getSharedObject()

QK.Notification = function(message, type)
    type = type or 'info'
    
    if Config.NotificationSystem == 'esx' then
        ESX.ShowNotification(message)
    else
        lib.notify({
            title = 'Quantom_Keys',
            description = message,
            type = type
        })
    end
end

QK.GetClosestVehicle = function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicles = ESX.Game.GetVehiclesInArea(playerCoords, Config.LockDistance)
    local closestVehicle, closestDistance = nil, Config.LockDistance
    
    for _, vehicle in ipairs(vehicles) do
        local distance = #(playerCoords - GetEntityCoords(vehicle))
        
        if distance < closestDistance then
            closestVehicle = vehicle
            closestDistance = distance
        end
    end
    
    return closestVehicle, closestDistance
end

local keyProp = nil

QK.PlayAnimation = function()
    if Config.UseAnimation then
        local playerPed = PlayerPedId()
        
        if not HasAnimDictLoaded(Config.AnimationDict) then
            RequestAnimDict(Config.AnimationDict)
            while not HasAnimDictLoaded(Config.AnimationDict) do
                Wait(0)
            end
        end
        
        if DoesEntityExist(keyProp) then
            DeleteEntity(keyProp)
        end
        
        local x, y, z = table.unpack(GetEntityCoords(playerPed))
        local propModel = `prop_cuff_keys_01`
        
        RequestModel(propModel)
        while not HasModelLoaded(propModel) do
            Wait(0)
        end
        
        keyProp = CreateObject(propModel, x, y, z+0.2, true, true, true)
        AttachEntityToEntity(keyProp, playerPed, GetPedBoneIndex(playerPed, 57005), 0.11, 0.03, -0.03, 90.0, 0.0, 0.0, true, true, false, true, 1, true)
        
        TaskPlayAnim(playerPed, Config.AnimationDict, Config.AnimationName, 8.0, 8.0, -1, 48, 1, false, false, false)
        SetTimeout(Config.AnimationDuration, function()
            StopAnimTask(playerPed, Config.AnimationDict, Config.AnimationName, 1.0)
            
            if DoesEntityExist(keyProp) then
                DeleteEntity(keyProp)
                keyProp = nil
            end
        end)
    end
end

QK.FlashVehicleLights = function(vehicle, lockStatus)
    if Config.FlashLights and DoesEntityExist(vehicle) then
        SetVehicleLights(vehicle, 2)
        
        for i = 1, Config.FlashCount do
            Wait(150)
            SetVehicleLights(vehicle, 0)
            Wait(150)
            SetVehicleLights(vehicle, 2)
        end
        
        SetVehicleLights(vehicle, 0)
    end
end

QK.ToggleVehicleLock = function(vehicle)
    if not DoesEntityExist(vehicle) then
        QK.Notification(Config.Locales['no_vehicle'], 'error')
        return
    end
    
    local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
    local lockStatus = GetVehicleDoorLockStatus(vehicle)
    
    ESX.TriggerServerCallback('quantom_keys:checkHasKey', function(hasKey)
        if hasKey then
            QK.PlayAnimation()
            
            if lockStatus == 1 then
                SetVehicleDoorsLocked(vehicle, 2)
                QK.Notification(Config.Locales['vehicle_locked'], 'success')
                PlaySoundFromEntity(-1, Config.LockSound, vehicle, "HUD_FRONTEND_DEFAULT_SOUNDSET", 1, 20)
            else
                SetVehicleDoorsLocked(vehicle, 1)
                QK.Notification(Config.Locales['vehicle_unlocked'], 'success')
                PlaySoundFromEntity(-1, Config.UnlockSound, vehicle, "HUD_FRONTEND_DEFAULT_SOUNDSET", 1, 20)
            end
            
            QK.FlashVehicleLights(vehicle, lockStatus)
        else
            QK.Notification(Config.Locales['not_owner'], 'error')
        end
    end, plate)
end

QK.GetVehicleByPlate = function(plate)
    local vehicles = ESX.Game.GetVehicles()
    
    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        local vehiclePlate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
        
        if vehiclePlate == plate then
            return vehicle
        end
    end
    
    return nil
end

_G.QK = QK