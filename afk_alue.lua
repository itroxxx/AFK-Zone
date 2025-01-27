local afkZone = vector3(211.450562, -944.584595, 30.678345)
local radius = 8.0

local isInAfkZone = false

-- Create a blip for the AFK zone
local blip = AddBlipForCoord(afkZone.x, afkZone.y, afkZone.z)
SetBlipSprite(blip, 76) -- Set the blip icon (1 is the default icon)
SetBlipDisplay(blip, 4) -- Set the blip to appear on both the minimap and the main map
SetBlipScale(blip, 0.5) -- Set the blip scale
SetBlipColour(blip, 2) -- Set the blip color (2 is green)
SetBlipAsShortRange(blip, true) -- Set the blip to only appear when nearby
BeginTextCommandSetBlipName("STRING")
AddTextComponentString("AFK Alue")
EndTextCommandSetBlipName(blip)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Check every second
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - afkZone)

        if distance <= radius and not isInAfkZone then
            isInAfkZone = true
            exports.ox_lib:notify({
                id = 'afk_zone_enter',
                title = 'AFK Alue',
                description = 'Menit AFK alueelle',
                type = 'success',
                position = 'top-right',
                duration = 3000,
                showDuration = true
            })
            -- Make player semi-transparent and non-collidable with vehicles
            SetEntityAlpha(playerPed, 153, false)
            SetEntityCollision(playerPed, true, true) -- Enable collision with the world but not with vehicles
            for _, player in pairs(GetActivePlayers()) do
                if player ~= PlayerId() then
                    local ped2 = GetPlayerPed(player)
                    SetEntityNoCollisionEntity(playerPed, ped2, true)
                    local veh2 = GetVehiclePedIsIn(ped2, false)
                    if veh2 ~= 0 then
                        SetEntityNoCollisionEntity(playerPed, veh2, true)
                    end
                end
            end
        elseif distance > radius and isInAfkZone then
            isInAfkZone = false
            exports.ox_lib:notify({
                id = 'afk_zone_exit',
                title = 'AFK Alue',
                description = 'Poistuit AFK alueelta',
                type = 'error',
                position = 'top-right',
                duration = 3000,
                showDuration = true
            })
            -- Reset player visibility and collision
            ResetEntityAlpha(playerPed)
            SetEntityCollision(playerPed, true, true)
            for _, player in pairs(GetActivePlayers()) do
                if player ~= PlayerId() then
                    local ped2 = GetPlayerPed(player)
                    SetEntityNoCollisionEntity(playerPed, ped2, false)
                    local veh2 = GetVehiclePedIsIn(ped2, false)
                    if veh2 ~= 0 then
                        SetEntityNoCollisionEntity(playerPed, veh2, false)
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isInAfkZone then
            DisablePlayerFiring(PlayerId(), true)
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 142, true) -- Melee Attack Alternate
            DisableControlAction(0, 106, true) -- Vehicle Mouse Control Override
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000) -- 5 seconds
        if isInAfkZone then
            TriggerServerEvent('afk_zone:giveMoney')
        end
    end
end)
