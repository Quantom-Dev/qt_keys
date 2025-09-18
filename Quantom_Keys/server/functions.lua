local QKS = {}
local ESX = exports['es_extended']:getSharedObject()
local ox_inventory = exports.ox_inventory

QKS.CheckHasKey = function(source, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return false end
    
    local items = ox_inventory:Search(source, 'slots', 'vehicle_key')
    
    if items then
        for _, item in pairs(items) do
            if item.metadata and item.metadata.plate == plate then
                return true
            end
        end
    end
    
    return false
end

QKS.CheckIsVehicleOwner = function(source, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return false end
    
    local result = MySQL.Sync.fetchAll('SELECT owner FROM owned_vehicles WHERE plate = ?', {plate})
    
    if result and #result > 0 then
        return result[1].owner == xPlayer.identifier
    end
    
    return false
end

QKS.CreateKey = function(source, plate, model)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return false end
    
    local keyMetadata = {
        plate = plate,
        model = model or 'Inconnu',
        description = 'Clé pour ' .. plate
    }
    
    local success = ox_inventory:AddItem(source, 'vehicle_key', 1, keyMetadata)
    
    return success
end

QKS.CopyKey = function(source, targetId, plate, model)
    local xPlayer = ESX.GetPlayerFromId(source)
    local tPlayer = ESX.GetPlayerFromId(targetId)
    
    if not xPlayer or not tPlayer then return false end
    
    local hasAlready = QKS.CheckHasKey(targetId, plate)
    
    if not hasAlready then
        local keyMetadata = {
            plate = plate,
            model = model or 'Inconnu',
            description = 'Clé pour ' .. plate
        }
        
        local success = ox_inventory:AddItem(targetId, 'vehicle_key', 1, keyMetadata)
        
        return success
    end
    
    return false
end

QKS.GetOwnedKeys = function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return {} end
    
    local items = ox_inventory:Search(source, 'slots', 'vehicle_key')
    local keys = {}
    
    if items then
        for _, item in pairs(items) do
            if item.metadata and item.metadata.plate then
                table.insert(keys, {
                    plate = item.metadata.plate,
                    model = item.metadata.model or 'Inconnu'
                })
            end
        end
    end
    
    return keys
end

_G.QKS = QKS