local ESX = exports['es_extended']:getSharedObject()

CreateThread(function()
end)

ESX.RegisterServerCallback('quantom_keys:checkHasKey', function(source, cb, plate)
    local hasKey = QKS.CheckHasKey(source, plate)
    cb(hasKey)
end)

ESX.RegisterServerCallback('quantom_keys:checkVehicleOwnership', function(source, cb, plate)
    local isOwner = QKS.CheckIsVehicleOwner(source, plate)
    local hasKey = QKS.CheckHasKey(source, plate)
    cb(hasKey, isOwner)
end)

ESX.RegisterServerCallback('quantom_keys:getOwnedKeys', function(source, cb)
    local keys = QKS.GetOwnedKeys(source)
    cb(keys)
end)

RegisterNetEvent('quantom_keys:createKey')
AddEventHandler('quantom_keys:createKey', function(plate, model)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    local isOwner = QKS.CheckIsVehicleOwner(source, plate)
    
    if isOwner then
        QKS.CreateKey(source, plate, model)
    end
end)

RegisterNetEvent('quantom_keys:giveKey')
AddEventHandler('quantom_keys:giveKey', function(targetId, plate, model)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local tPlayer = ESX.GetPlayerFromId(targetId)
    
    if not xPlayer or not tPlayer then return end
    
    local hasKey = QKS.CheckHasKey(source, plate)
    
    if hasKey then
        local success = QKS.CopyKey(source, targetId, plate, model)
        
        if success then
            TriggerClientEvent('quantom_keys:receiveKey', targetId, plate, model)
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Quantom_Keys',
                description = Config.Locales['key_given'],
                type = 'success'
            })
        end
    end
end)

AddEventHandler('esx_vehicleshop:setVehicleOwned', function(source, vehicleProps)
    if vehicleProps and vehicleProps.plate then
        local plate = ESX.Math.Trim(vehicleProps.plate)
        local model = GetDisplayNameFromVehicleModel(vehicleProps.model)
        
        QKS.CreateKey(source, plate, model)
    end
end)

RegisterNetEvent('quantom_keys:requestKey')
AddEventHandler('quantom_keys:requestKey', function(plate, model)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    local isOwner = QKS.CheckIsVehicleOwner(source, plate)
    
    if isOwner then
        local hasKey = QKS.CheckHasKey(source, plate)
        
        if not hasKey then
            QKS.CreateKey(source, plate, model)
        end
    end
end)

ESX.RegisterCommand('givekey', 'admin', function(xPlayer, args, showError)
    local targetId = args.playerId
    local plate = args.plate
    local model = args.model or 'Inconnu'
    
    if targetId and plate then
        QKS.CreateKey(targetId, plate, model)
        xPlayer.showNotification('Clé créée pour ' .. plate .. ' et donnée au joueur ' .. targetId)
    else
        showError('Utilisation: /givekey [playerId] [plate] [model]')
    end
end, true, {help = 'Donner une clé de véhicule à un joueur', validate = true, arguments = {
    {name = 'playerId', help = 'ID du joueur', type = 'number'},
    {name = 'plate', help = 'Plaque du véhicule', type = 'string'},
    {name = 'model', help = 'Modèle du véhicule (optionnel)', type = 'string', optional = true}
}})