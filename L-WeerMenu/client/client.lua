ESX = nil
CurrentWeather = 'EXTRASUNNY'
local lastWeather = CurrentWeather
local baseTime = 0
local timeOffset = 0
local timer = 0
local freezeTime = false
local blackout = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local weermenu = {  
	[1] = {label = _U("lommelontop1"), value = "weer_menu"}
}

RegisterCommand(Config.Command, function(source, args, rawCommand)
    local elements = {}
    for i=1, #weermenu, 1 do
        table.insert(elements, weermenu[i])
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'weer_menu', {
        title = _U('lommelontop1'),
        align = Config.MenuAlign,
        elements = elements

    }, function(data, menu)
        menu.close()
		if data.current.value == "weer_menu" then
			WeerMenu()
        end
    end, function(data, menu)
        menu.close()
    end)
end)

function WeerMenu()
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'weer_menu',
        {
            title    = _U('lommelontop2'),
			align    = Config.MenuAlign,
            elements = {
				{label = _U('lommelontop3'), 	value = 'weer_fixn'},
				{label = _U('lommelontop4'), 	value = 'menu_weer'},
				{label = _U('lommelontop5'), 	value = 'weer_menu'},
				{label = _U('lommelontop6'), 	value = 'weer_gdmn'},
				{label = _U('lommelontop7'), 	value = 'weer_midg'},
				{label = _U('lommelontop8'), 	value = 'weer_avon'},
				{label = _U('lommelontop9'), 	value = 'weer_nigt'},
				{label = _U('lommelontop10'), 	value = 'weer_kpot'},
				{label = _U('lommelontop11'), 	value = 'weer_snow'},
				{label = _U('lommelontop12'), 	value = 'weer_snow2'},
				{label = _U('lommelontop13'), 	value = 'weer_snow3'},
				{label = _U('lommelontop14'), 	value = 'weer_regen'},
				{label = _U('lommelontop15'), 	value = 'weer_omwer'},
				{label = _U('lommelontop16'), 	value = 'weer_zomer'},
            }
        },
        function(data, menu)
			if data.current.value == 'weer_fixn' then
				ExecuteCommand('weather clear')
            elseif data.current.value == 'menu_weer' then
				ExecuteCommand('freezetime')
			elseif data.current.value == 'weer_menu' then
				ExecuteCommand('freezeweather')
			elseif data.current.value == 'weer_gdmn' then
				ExecuteCommand('morning')
			elseif data.current.value == 'weer_midg' then
				ExecuteCommand('noon')
			elseif data.current.value == 'weer_avon' then
				ExecuteCommand('evening')
			elseif data.current.value == 'weer_nigt' then
				ExecuteCommand('night')
			elseif data.current.value == 'weer_kpot' then
				ExecuteCommand('blackout')
			elseif data.current.value == 'weer_snow' then
				ExecuteCommand('weather snow')
			elseif data.current.value == 'weer_snow2' then
				ExecuteCommand('weather xmas')
			elseif data.current.value == 'weer_snow3' then
				ExecuteCommand('weather snowlight')
			elseif data.current.value == 'weer_regen' then
				ExecuteCommand('weather rain')
			elseif data.current.value == 'weer_omwer' then
				ExecuteCommand('weather thunder')
			elseif data.current.value == 'weer_zomer' then
				ExecuteCommand('weather extrasunny')
			end
        end,
        function(data, menu)
            menu.close()
        end
    )
end

RegisterNetEvent('L-WeerMenu:updateWeather')
AddEventHandler('L-WeerMenu:updateWeather', function(NewWeather, newblackout)
    CurrentWeather = NewWeather
    blackout = newblackout
end)

RegisterNetEvent('L-WeerMenu:updateWeather')
AddEventHandler('L-WeerMenu:updateWeather', function(NewWeather, newblackout)
    CurrentWeather = NewWeather
    blackout = newblackout
end)

Citizen.CreateThread(function()
    while true do
        if lastWeather ~= CurrentWeather then
            lastWeather = CurrentWeather
            SetWeatherTypeOverTime(CurrentWeather, 15.0)
            Citizen.Wait(15000)
        end
        Citizen.Wait(100)
        SetBlackout(blackout)
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypePersist(lastWeather)
        SetWeatherTypeNow(lastWeather)
        SetWeatherTypeNowPersist(lastWeather)
        if lastWeather == 'XMAS' then
            SetForceVehicleTrails(true)
            SetForcePedFootstepsTracks(true)
        else
            SetForceVehicleTrails(false)
            SetForcePedFootstepsTracks(false)
        end
    end
end)

RegisterNetEvent('L-WeerMenu:updateTime')
AddEventHandler('L-WeerMenu:updateTime', function(base, offset, freeze)
    freezeTime = freeze
    timeOffset = offset
    baseTime = base
end)

Citizen.CreateThread(function()
    local hour = 0
    local minute = 0
    while true do
        Citizen.Wait(0)
        local newBaseTime = baseTime
        if GetGameTimer() - 500  > timer then
            newBaseTime = newBaseTime + 0.25
            timer = GetGameTimer()
        end
        if freezeTime then
            timeOffset = timeOffset + baseTime - newBaseTime			
        end
        baseTime = newBaseTime
        hour = math.floor(((baseTime+timeOffset)/60)%24)
        minute = math.floor((baseTime+timeOffset)%60)
        NetworkOverrideClockTime(hour, minute, 0)
    end
end)

AddEventHandler('playerSpawned', function()
    TriggerServerEvent('L-WeerMenu:requestSync')
end)

function ShowNotification(text, blink)
    if blink == nil then blink = false end
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(text)
    DrawNotification(blink, false)
end

RegisterNetEvent('L-WeerMenu:notify')
AddEventHandler('L-WeerMenu:notify', function(message, blink)
    ShowNotification(message, blink)
end)