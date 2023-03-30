ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

DynamicWeather = false
debugprint     = false
AvailableWeatherTypes = {
    'EXTRASUNNY', 
    'CLEAR', 
    'NEUTRAL', 
    'SMOG', 
    'FOGGY', 
    'OVERCAST', 
    'CLOUDS', 
    'CLEARING', 
    'RAIN', 
    'THUNDER', 
    'SNOW', 
    'BLIZZARD', 
    'SNOWLIGHT', 
    'XMAS', 
    'HALLOWEEN',
}

CurrentWeather = "EXTRASUNNY"
local baseTime = 0
local timeOffset = 0
local freezeTime = false
local blackout = false
local newWeatherTimer = 10

RegisterServerEvent('L-WeerMenu:requestSync')
AddEventHandler('L-WeerMenu:requestSync', function()
    TriggerClientEvent('L-WeerMenu:updateWeather', -1, CurrentWeather, blackout)
    TriggerClientEvent('L-WeerMenu:updateTime', -1, baseTime, timeOffset, freezeTime)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local newBaseTime = os.time(os.date("!*t"))/2 + 360
        if freezeTime then
            timeOffset = timeOffset + baseTime - newBaseTime			
        end
        baseTime = newBaseTime
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        TriggerClientEvent('L-WeerMenu:updateTime', -1, baseTime, timeOffset, freezeTime)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000)
        TriggerClientEvent('L-WeerMenu:updateWeather', -1, CurrentWeather, blackout)
    end
end)

Citizen.CreateThread(function()
    while true do
        newWeatherTimer = newWeatherTimer - 1
        Citizen.Wait(60000)
        if newWeatherTimer == 0 then
            if DynamicWeather then
                NextWeatherStage()
            end
            newWeatherTimer = 10
        end
    end
end)

function ShiftToMinute(minute)
    timeOffset = timeOffset - ( ( (baseTime+timeOffset) % 60 ) - minute )
end

function ShiftToHour(hour)
    timeOffset = timeOffset - ( ( ((baseTime+timeOffset)/60) % 24 ) - hour ) * 60
end

RegisterCommand("time", function(source, args, rawCommand)
    local xPlayer    = ESX.GetPlayerFromId(source)
	local identifier = GetPlayerIdentifiers(source)[1]

	if checkperm(identifier) then
		if tonumber(args[1]) ~= nil and tonumber(args[2]) ~= nil then
            local argh = tonumber(args[1])
            local argm = tonumber(args[2])
            if argh < 24 then
                ShiftToHour(argh)
            else
                ShiftToHour(0)
            end
            if argm < 60 then
                ShiftToMinute(argm)
            else
                ShiftToMinute(0)
            end
			TriggerEvent('L-WeerMenu:requestSync')
		end

	elseif checkperm(identifier) then
		if isAllowedToChange(source) then
			if tonumber(args[1]) ~= nil and tonumber(args[2]) ~= nil then
				local argh = tonumber(args[1])
            	local argm = tonumber(args[2])
            	if argh < 24 then
                	ShiftToHour(argh)
            	else
                	ShiftToHour(0)
            	end
            	if argm < 60 then
                	ShiftToMinute(argm)
            	else
                	ShiftToMinute(0)
            	end
            	local newtime = math.floor(((baseTime+timeOffset)/60)%24) .. ":"
				local minute = math.floor((baseTime+timeOffset)%60)
            	if minute < 10 then
                	newtime = newtime .. "0" .. minute
            	else
                	newtime = newtime .. minute
            	end
				TriggerClientEvent('esx:showNotification', source,  _U('lommelontop17' .. newtime .. "~s~!"))
				TriggerEvent('L-WeerMenu:requestSync')
    		else
				msg(xPlayer.source)
			end
    	end
	end
end)

RegisterCommand("freezetime", function(source, args, rawCommand)
    local xPlayer    = ESX.GetPlayerFromId(source)
	local identifier = GetPlayerIdentifiers(source)[1]
	
    if checkperm(identifier) then
		if isAllowedToChange(source) then
        	freezeTime = not freezeTime
			if freezeTime then
				TriggerClientEvent('esx:showNotification', source, _U('lommelontop18'))
			else
				TriggerClientEvent('esx:showNotification', source, _U('lommelontop19'))
			end
		end
    else
		msg(xPlayer.source)
    end
end)

RegisterCommand("freezeweather", function(source, args, rawCommand)
	local xPlayer    = ESX.GetPlayerFromId(source)
	local identifier = GetPlayerIdentifiers(source)[1]
	
    if checkperm(identifier) then
		if isAllowedToChange(source) then
			DynamicWeather = not DynamicWeather
			if not DynamicWeather then
				TriggerClientEvent('esx:showNotification', source, _U('lommelontop20'))
			else
				TriggerClientEvent('esx:showNotification', source, _U('lommelontop21'))
			end
		end
    else
		msg(xPlayer.source)
    end
end)

RegisterCommand("weather", function(source, args, rawCommand)
	local xPlayer    = ESX.GetPlayerFromId(source)
	local identifier = GetPlayerIdentifiers(source)[1]

	if checkperm(identifier) then
		local validWeatherType = false
		if args[1] == nil then
            print("Ongeldige syntaxis, correcte syntaxis is: /weather <weertype>")
            return
        else
			for i,wtype in ipairs(AvailableWeatherTypes) do
                if wtype == string.upper(args[1]) then
                    validWeatherType = true
                end
            end
            if validWeatherType then
                print("Het weer is bijgewerkt.")
                CurrentWeather = string.upper(args[1])
                newWeatherTimer = 10
                TriggerEvent('L-WeerMenu:requestSync')
            else
                print("Ongeldig weertype, geldige weertypes zijn: \nEXTRASUNNY CLEAR NEUTRAL SMOG FOGGY OVERCAST CLOUDS CLEARING RAIN THUNDER SNOW BLIZZARD SNOWLIGHT XMAS HALLOWEEN ")
            end
		end
	else
		if isAllowedToChange(source) then
			local validWeatherType = false
			if args[1] == nil then
				TriggerClientEvent('esx:showNotification', source, _U('lommelontop22'))
            else
				for i,wtype in ipairs(AvailableWeatherTypes) do
                    if wtype == string.upper(args[1]) then
                        validWeatherType = true
                    end
                end
                if validWeatherType then
                    TriggerClientEvent('L-WeerMenu:notify', source, _U('lommelontop23' .. string.lower(args[1]) .. "~s~."))
                    CurrentWeather = string.upper(args[1])
                    newWeatherTimer = 10
                    TriggerEvent('L-WeerMenu:requestSync')
                else
					TriggerClientEvent('esx:showNotification', source, _U('lommelontop24'))
                end
			end
    	else
			msg(xPlayer.source)
    	end
	end
end)

RegisterCommand("blackout", function(source, args, rawCommand)
	local xPlayer    = ESX.GetPlayerFromId(source)
	local identifier = GetPlayerIdentifiers(source)[1]
	
	if checkperm(identifier) then
		blackout = not blackout
		if blackout then
			TriggerClientEvent('esx:showNotification', source, _U('lommelontop25'))
		else
			TriggerClientEvent('esx:showNotification', source, _U('lommelontop26'))
		end
	else
		if isAllowedToChange(source) then
			blackout = not blackout
            if blackout then
                TriggerClientEvent('L-WeerMenu:notify', source, _U('lommelontop25'))
            else
                TriggerClientEvent('L-WeerMenu:notify', source, _U('lommelontop26'))
            end
            TriggerEvent('L-WeerMenu:requestSync')
    	else
			msg(xPlayer.source)
		end
    end
end)

RegisterCommand("morning", function(source, args, rawCommand)
	local xPlayer    = ESX.GetPlayerFromId(source)
	local identifier = GetPlayerIdentifiers(source)[1]
	
	if checkperm(identifier) then
		if isAllowedToChange(source) then
			ShiftToMinute(0)
        	ShiftToHour(9)
			TriggerClientEvent('esx:showNotification', source, _U('lommelontop27'))
			TriggerEvent('L-WeerMenu:requestSync')
		end
    else
		msg(xPlayer.source)
    end
end)

RegisterCommand("noon", function(source, args, rawCommand)
	local xPlayer    = ESX.GetPlayerFromId(source)
	local identifier = GetPlayerIdentifiers(source)[1]
	
	if checkperm(identifier) then
		if isAllowedToChange(source) then
			ShiftToMinute(0)
        	ShiftToHour(12)
			TriggerClientEvent('esx:showNotification', source, _U('lommelontop28'))
			TriggerEvent('L-WeerMenu:requestSync')
		end
    else
		msg(xPlayer.source)
    end
end)

RegisterCommand("evening", function(source, args, rawCommand)
	local xPlayer    = ESX.GetPlayerFromId(source)
	local identifier = GetPlayerIdentifiers(source)[1]
	
	if checkperm(identifier) then
		if isAllowedToChange(source) then
			ShiftToMinute(0)
        	ShiftToHour(18)
			TriggerClientEvent('esx:showNotification', source, _U("lommelontop29"))
			TriggerEvent('L-WeerMenu:requestSync')
		end
    else
		msg(xPlayer.source)
    end
end)

RegisterCommand("night", function(source, args, rawCommand)
	local xPlayer    = ESX.GetPlayerFromId(source)
	local identifier = GetPlayerIdentifiers(source)[1]
	
	if checkperm(identifier) then
		if isAllowedToChange(source) then
			ShiftToMinute(0)
        	ShiftToHour(23)
			TriggerClientEvent('esx:showNotification', source, _U('lommelontop30'))
			TriggerEvent('L-WeerMenu:requestSync')
		end
    else
		msg(xPlayer.source)
    end
end)

function NextWeatherStage()
    if CurrentWeather == "CLEAR" or CurrentWeather == "CLOUDS" or CurrentWeather == "EXTRASUNNY"  then
        local new = math.random(1,2)
        if new == 1 then
            CurrentWeather = "CLEARING"
        else
            CurrentWeather = "OVERCAST"
        end
    elseif CurrentWeather == "CLEARING" or CurrentWeather == "OVERCAST" then
        local new = math.random(1,6)
        if new == 1 then
            if CurrentWeather == "CLEARING" then CurrentWeather = "FOGGY" else CurrentWeather = "RAIN" end
        elseif new == 2 then
            CurrentWeather = "CLOUDS"
        elseif new == 3 then
            CurrentWeather = "CLEAR"
        elseif new == 4 then
            CurrentWeather = "EXTRASUNNY"
        elseif new == 5 then
            CurrentWeather = "SMOG"
        else
            CurrentWeather = "FOGGY"
        end
    elseif CurrentWeather == "THUNDER" or CurrentWeather == "RAIN" then
        CurrentWeather = "CLEARING"
    elseif CurrentWeather == "SMOG" or CurrentWeather == "FOGGY" then
        CurrentWeather = "CLEAR"
    end
    TriggerEvent("L-WeerMenu:requestSync")
    if debugprint then
        print("Er is een nieuw willekeurig weertype gegenereerd: " .. CurrentWeather .. ".\n")
        print("Timer resetten naar 10 minuten.\n")
    end
end

function msg(player)
	TriggerClientEvent('esx:showNotification', player, _U('lommelontop31'))	
end
function checkperm(psteam)
	for i,v in pairs(Config.Admins) do
		if psteam == v then
			return true
		end
	end
	return false
end
function isAllowedToChange(player)
    local allowed = false
    for i,id in ipairs(Config.Admins) do
        for x,pid in ipairs(GetPlayerIdentifiers(player)) do
            if debugprint then print('admin id: ' .. id .. '\nplayer id:' .. pid) end
            if string.lower(pid) == string.lower(id) then
                allowed = true
            end
        end
    end
    return allowed
end