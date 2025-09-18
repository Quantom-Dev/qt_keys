local ESX = exports['es_extended']:getSharedObject()
local dealerMenuOpen = false
local interactionBlip = nil

RegisterCommand('cardealerkeys', function()
    TriggerEvent('quantom_keys:openCardealerMenu')
end, false)

RegisterCommand('testcardealermenu', function()
    OpenCardealerMenu(true)
end, false)

local function GetNearbyPlayers()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local players = ESX.Game.GetPlayersInArea(playerCoords, 10.0)
    local nearbyPlayers = {}
    
    for _, player in ipairs(players) do
        local targetId = GetPlayerServerId(player)
        
        if targetId ~= GetPlayerServerId(PlayerId()) then
            local targetName = GetPlayerName(player)
            
            table.insert(nearbyPlayers, {
                id = targetId,
                name = targetName
            })
        end
    end
    
    return nearbyPlayers
end

local function GetNearbyVehicles()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicles = ESX.Game.GetVehiclesInArea(playerCoords, 30.0)
    local nearbyVehicles = {}
    
    for _, vehicle in ipairs(vehicles) do
        local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
        local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
        
        table.insert(nearbyVehicles, {
            plate = plate,
            model = model
        })
    end
    
    return nearbyVehicles
end

local function CreateDealershipPoint()
    local interactionPoint = Config.MenuSettings.InteractionPoint
    
    if interactionPoint.blip and interactionPoint.blip.enabled then
        interactionBlip = AddBlipForCoord(interactionPoint.coords.x, interactionPoint.coords.y, interactionPoint.coords.z)
        SetBlipSprite(interactionBlip, interactionPoint.blip.sprite)
        SetBlipColour(interactionBlip, interactionPoint.blip.color)
        SetBlipScale(interactionBlip, interactionPoint.blip.scale)
        SetBlipAsShortRange(interactionBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(interactionPoint.blip.label)
        EndTextCommandSetBlipName(interactionBlip)
    end
    
    if Config.UseTarget then
        exports.ox_target:addSphereZone({
            coords = interactionPoint.coords,
            radius = interactionPoint.radius,
            options = {
                {
                    name = 'quantom_keys:dealerpoint',
                    icon = 'fas fa-key',
                    label = 'Gestion des clés',
                    canInteract = function()
                        local playerData = ESX.GetPlayerData()
                        return playerData.job and playerData.job.name == 'cardealer'
                    end,
                    onSelect = function()
                        TriggerEvent('quantom_keys:openCardealerMenu')
                    end
                }
            }
        })
    else
        CreateThread(function()
            while true do
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local distance = #(playerCoords - interactionPoint.coords)
                local sleep = 1000
                
                if distance < 10.0 then
                    sleep = 0
                    
                    if interactionPoint.marker and interactionPoint.marker.enabled then
                        DrawMarker(
                            interactionPoint.marker.type,
                            interactionPoint.coords.x, interactionPoint.coords.y, interactionPoint.coords.z - 1.0,
                            0.0, 0.0, 0.0,
                            0.0, 0.0, 0.0,
                            interactionPoint.marker.size.x, interactionPoint.marker.size.y, interactionPoint.marker.size.z,
                            interactionPoint.marker.color.r, interactionPoint.marker.color.g, interactionPoint.marker.color.b, interactionPoint.marker.color.a,
                            interactionPoint.marker.bobUpAndDown, interactionPoint.marker.rotate, 2, false, nil, nil, false
                        )
                    end
                    
                    if distance < interactionPoint.radius then
                        local playerData = ESX.GetPlayerData()
                        if playerData.job and playerData.job.name == 'cardealer' then
                            ESX.ShowHelpNotification(Config.Locales['press_e_interact'])
                            
                            if IsControlJustReleased(0, Config.MenuSettings.InteractionKey) then
                                TriggerEvent('quantom_keys:openCardealerMenu')
                            end
                        end
                    end
                end
                
                Wait(sleep)
            end
        end)
    end
end

RegisterNetEvent('quantom_keys:openCardealerMenu')
AddEventHandler('quantom_keys:openCardealerMenu', function()
    local playerData = ESX.GetPlayerData()
    
    if playerData.job and playerData.job.name == 'cardealer' then
        OpenCardealerMenu()
    else
        TriggerEvent('quantom_keys:notify', Config.Locales['not_cardealer'], 'error')
    end
end)

function OpenCardealerMenu(bypass)
    if dealerMenuOpen then return end
    
    dealerMenuOpen = true
    
    local players = GetNearbyPlayers()
    local vehicles = GetNearbyVehicles()
    
    if bypass then
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = 'openCardealerMenu',
            job = 'cardealer',
            playerId = GetPlayerServerId(PlayerId()),
            players = players,
            vehicles = {
                {plate = "TEST123", model = "Adder"},
                {plate = "ABC456", model = "Sultan"}
            },
            keys = {
                {plate = "KEY789", model = "T20"},
                {plate = "XYZ123", model = "Zentorno"}
            }
        })
        return
    end
    
    ESX.TriggerServerCallback('quantom_keys:getOwnedKeys', function(keys)
        SetNuiFocus(true, true)
        
        Wait(100)
        
        SendNUIMessage({
            type = 'openCardealerMenu',
            job = 'cardealer',
            playerId = GetPlayerServerId(PlayerId()),
            players = players,
            vehicles = vehicles,
            keys = keys or {}
        })
        
        CreateThread(function()
            while dealerMenuOpen do
                Wait(2000)
                
                local updatedPlayers = GetNearbyPlayers()
                local updatedVehicles = GetNearbyVehicles()
                
                SendNUIMessage({
                    type = 'updateNearbyData',
                    players = updatedPlayers,
                    vehicles = updatedVehicles
                })
            end
        end)
    end)
end

RegisterNetEvent('quantom_keys:notify')
AddEventHandler('quantom_keys:notify', function(message, type)
    if Config.NotificationSystem == 'esx' then
        ESX.ShowNotification(message)
    else
        lib.notify({
            title = 'Quantom_Keys',
            description = message,
            type = type or 'info'
        })
    end
end)

function CloseCardealerMenu()
    dealerMenuOpen = false
    SetNuiFocus(false, false)
end

RegisterNUICallback('closeMenu', function(data, cb)
    CloseCardealerMenu()
    cb('ok')
end)

RegisterNUICallback('createKey', function(data, cb)
    local targetId = data.targetId
    local plate = data.plate
    local model = data.model
    
    TriggerServerEvent('quantom_keys:cardealerCreateKey', targetId, plate, model)
    cb('ok')
end)

RegisterNUICallback('giveKey', function(data, cb)
    local targetId = data.targetId
    local plate = data.plate
    local model = data.model
    
    TriggerServerEvent('quantom_keys:giveKey', targetId, plate, model)
    cb('ok')
end)

CreateThread(function()
    if Config.MenuSettings.UseInteractionPoint then
        CreateDealershipPoint()
    end
    
    if Config.MenuSettings.UseKeyBinding then
        RegisterKeyMapping('cardealerkeys', 'Ouvrir le menu concessionnaire', 'keyboard', GetControlInstructionalButton(0, Config.MenuSettings.KeyBinding, true))
        
        CreateThread(function()
            while true do
                Wait(0)
                
                local playerData = ESX.GetPlayerData()
                
                if playerData.job and playerData.job.name == 'cardealer' then
                    if IsControlJustReleased(0, Config.MenuSettings.KeyBinding) then
                        TriggerEvent('quantom_keys:openCardealerMenu')
                    end
                else
                    Wait(1000)
                end
            end
        end)
    end
end)

exports('forceOpenCardealerMenu', function()
    OpenCardealerMenu(true)
end)