local QBCore = exports['qb-core']:GetCoreObject()

local isLightHelloEnabled = true
local hasPlayedRecently = false


RegisterCommand("selamlaac", function()
    isLightHelloEnabled = true
    QBCore.Functions.Notify("Far selamlama açıldı.", "success")
end)

RegisterCommand("selamlakapa", function()
    isLightHelloEnabled = false
    QBCore.Functions.Notify("Far selamlama kapatıldı.", "error")
end)


local function playLightSequence(vehicle)
    if not DoesEntityExist(vehicle) then return end


    SetVehicleIndicatorLights(vehicle, 0, true)
    Wait(200)
    SetVehicleIndicatorLights(vehicle, 0, false)
    Wait(200)


    SetVehicleIndicatorLights(vehicle, 1, true)
    Wait(200)
    SetVehicleIndicatorLights(vehicle, 1, false)
    Wait(200)


    for i = 1, 3 do
        SetVehicleLights(vehicle, 2)
        Wait(200)
        SetVehicleLights(vehicle, 1)
        Wait(200)
    end


    for i = 1, 2 do
        SetVehicleIndicatorLights(vehicle, 0, true)
        SetVehicleIndicatorLights(vehicle, 1, true)
        Wait(300)
        SetVehicleIndicatorLights(vehicle, 0, false)
        SetVehicleIndicatorLights(vehicle, 1, false)
        Wait(300)
    end


    StartVehicleHorn(vehicle, 200, GetHashKey("NORMAL"), false)


    SetVehicleLights(vehicle, 0)
end

CreateThread(function()
    while true do
        Wait(1000)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for vehicle in EnumerateVehicles() do
            local dist = #(playerCoords - GetEntityCoords(vehicle))
            if dist < 5.0 then
                if not hasPlayedRecently then
                    local plate = QBCore.Functions.GetPlate(vehicle)
                    local player = QBCore.Functions.GetPlayerData()

                    if isLightHelloEnabled and player and HasHelloCard(player) then
                        if GetVehicleOwner(vehicle) == GetPlayerServerId(PlayerId()) then
                            hasPlayedRecently = true
                            playLightSequence(vehicle)
                            SetTimeout(10000, function()
                                hasPlayedRecently = false
                            end)
                        end
                    end
                end
            end
        end
    end
end)

function HasHelloCard(player)
    if not player or not player.items then return false end
    for _, item in pairs(player.items) do
        if item.name == "selamlama_karti" then
            return true
        end
    end
    return false
end

function GetVehicleOwner(vehicle)
    return GetPlayerServerId(PlayerId())
end

function EnumerateVehicles()
    return coroutine.wrap(function()
        local handle, vehicle = FindFirstVehicle()
        local finished = false
        repeat
            coroutine.yield(vehicle)
            finished, vehicle = FindNextVehicle(handle)
        until not finished
        EndFindVehicle(handle)
    end)
end
