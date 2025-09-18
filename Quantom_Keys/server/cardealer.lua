local ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('quantom_keys:cardealerCreateKey')
AddEventHandler('quantom_keys:cardealerCreateKey', function(targetId, plate, model)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local tPlayer = ESX.GetPlayerFromId(targetId)
    
    if not xPlayer or xPlayer.job.name ~= 'cardealer' then return end
    
    if not tPlayer then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Quantom_Keys',
            description = 'Joueur introuvable',
            type = 'error'
        })
        return
    end
    
    local success = QKS.CreateKey(targetId, plate, model)
    
    if success then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Quantom_Keys',
            description = 'Clé créée et donnée à ' .. GetPlayerName(targetId),
            type = 'success'
        })
        
        TriggerClientEvent('ox_lib:notify', targetId, {
            title = 'Quantom_Keys',
            description = 'Vous avez reçu une clé pour ' .. model .. ' (' .. plate .. ')',
            type = 'success'
        })
        
        print(string.format("[Quantom_Keys] Le concessionnaire %s (ID: %s) a créé une clé pour %s (ID: %s) - Véhicule: %s (%s)", 
            GetPlayerName(source), source, GetPlayerName(targetId), targetId, model, plate))
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Quantom_Keys',
            description = 'Impossible de créer la clé',
            type = 'error'
        })
    end
end)

local function CanDealerAccessVehicle(source, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer or xPlayer.job.name ~= 'cardealer' then
        return false
    end
    
    return true
end

ESX.RegisterCommand('createvehiclekey', {'admin', 'superadmin', 'cardealer'}, function(xPlayer, args, showError)
    local targetId = args.playerId
    local plate = args.plate
    local model = args.model or 'Véhicule'
    
    if not targetId or not plate then
        showError('Utilisation: /createvehiclekey [playerId] [plate] [model]')
        return
    end
    
    local tPlayer = ESX.GetPlayerFromId(targetId)
    
    if not tPlayer then
        showError('Joueur introuvable')
        return
    end
    
    if xPlayer.job.name == 'cardealer' and not CanDealerAccessVehicle(xPlayer.source, plate) then
        showError('Vous n\'avez pas accès à ce véhicule')
        return
    end
    
    local success = QKS.CreateKey(targetId, plate, model)
    
    if success then
        xPlayer.showNotification('Clé créée pour ' .. plate .. ' et donnée au joueur ' .. targetId)
        tPlayer.showNotification('Vous avez reçu une clé pour ' .. model .. ' (' .. plate .. ')')
    else
        showError('Impossible de créer la clé')
    end
    
end, true, {help = 'Créer une clé de véhicule pour un joueur', validate = true, arguments = {
    {name = 'playerId', help = 'ID du joueur', type = 'number'},
    {name = 'plate', help = 'Plaque du véhicule', type = 'string'},
    {name = 'model', help = 'Modèle du véhicule (optionnel)', type = 'string', optional = true}
}})

RegisterNetEvent('quantom_keys:vehicleSold')
AddEventHandler('quantom_keys:vehicleSold', function(targetId, vehicleProps, dealerId)
    local source = source
    
    if source ~= '' and source ~= 0 then
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer or xPlayer.job.name ~= 'cardealer' then
            return
        end
    end
    
    if not targetId or not vehicleProps or not vehicleProps.plate then
        return
    end
    
    local plate = ESX.Math.Trim(vehicleProps.plate)
    local model = GetDisplayNameFromVehicleModel(vehicleProps.model) or 'Véhicule'
    
    QKS.CreateKey(targetId, plate, model)
    
    if dealerId then
        TriggerClientEvent('ox_lib:notify', dealerId, {
            title = 'Quantom_Keys',
            description = 'Clé créée pour le client',
            type = 'success'
        })
    end
    
    TriggerClientEvent('ox_lib:notify', targetId, {
        title = 'Quantom_Keys',
        description = 'Vous avez reçu les clés de votre nouveau véhicule',
        type = 'success'
    })
end)

if GetResourceState('esx_vehicleshop') == 'started' then
    AddEventHandler('esx_vehicleshop:vehicleSold', function(source, targetId, vehicleProps)
        if vehicleProps and vehicleProps.plate then
            local plate = ESX.Math.Trim(vehicleProps.plate)
            local model = GetDisplayNameFromVehicleModel(vehicleProps.model) or 'Véhicule'
            
            QKS.CreateKey(targetId, plate, model)
            
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Quantom_Keys',
                description = 'Clé créée pour le client',
                type = 'success'
            })
            
            TriggerClientEvent('ox_lib:notify', targetId, {
                title = 'Quantom_Keys',
                description = 'Vous avez reçu les clés de votre nouveau véhicule',
                type = 'success'
            })
        end
    end)
end