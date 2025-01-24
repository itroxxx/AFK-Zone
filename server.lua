ESX = exports['es_extended']:getSharedObject()

RegisterServerEvent('afk_zone:giveMoney')
AddEventHandler('afk_zone:giveMoney', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addInventoryItem('money', 50)
    end
end)