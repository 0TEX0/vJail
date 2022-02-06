ESX = nil
local playersInJail = {}



TriggerEvent('OTEXO&KraKss:esx:getSharedObject', function(obj) ESX = obj end)



function sendDiscord(name, message)
	local content = {
        {
        	["color"] = '14561591',
            ["author"] = {
		        ["name"] = "".. name .."",
		        ["icon_url"] = 'https://i.pinimg.com/originals/fe/a5/57/fea55780b562eb2032641d1867ee4098.png',
		    },
            ["description"] = message,
            ["footer"] = {
            ["text"] = "Jail by 0TEX0 https://discord.gg/nF9aHrSJh6",
            }
        }
    }
  	PerformHttpRequest(Config.discordwebhooklink, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = content}), { ['Content-Type'] = 'application/json' })
end



AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
 
	MySQL.Async.fetchAll('SELECT jail_time FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		if result[1] and result[1].jail_time > 0 then
			TriggerEvent('esx_jail:sendToJail', xPlayer.source, result[1].jail_time, true)
		end
	end)
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
	playersInJail[playerId] = nil
end)

MySQL.ready(function()
	Citizen.Wait(2000)
	local xPlayers = ESX.GetPlayers()

	for i=1, #xPlayers do
		Citizen.Wait(100)
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

		MySQL.Async.fetchAll('SELECT jail_time FROM users WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier
		}, function(result)
			if result[1] and result[1].jail_time > 0 then
				TriggerEvent('esx_jail:sendToJail', xPlayer.source, result[1].jail_time, true)
			end
		end)
	end
end)



ESX.RegisterCommand('jail', 'admin', function(xPlayer, args, showError)
	local message = args.message
	local src = GetPlayerName(xPlayer.source)
	
sendDiscord("Joueur Jail (/jail)", "**Joueur:** "..GetPlayerName(args.playerId).."\n**Temps:** ".. args.time .." minutes\n**Jail par:** "..GetPlayerName(xPlayer.source).."\n**Reason :** "..args.message)
TriggerEvent('esx_jail:sendToJail', args.playerId, args.time * 60, message, src)
end, true, {help = 'Jail a player', validate = true, arguments = {
	{name = 'playerId', help = 'Id joueur', type = 'playerId'},
	{name = 'time', help = 'Temps de jail', type = 'number'},
	{name = 'message', help = 'raison du jail', type = 'any'}
}})

ESX.RegisterCommand('unjail', 'admin', function(xPlayer, args, showError)
	unjailPlayer(args.playerId)
--	sendDiscord("Joueur UnJail (/unjail)", "**Joueur:** "..GetPlayerName(args.playerId).."\n**UnJail par:** "..GetPlayerName(xPlayer.source).."")
end, true, {help = 'Unjail joueur', validate = true, arguments = {
	{name = 'playerId', help = 'Id joueur', type = 'playerId'}
}})

RegisterNetEvent('esx_jail:unjail')
AddEventHandler('esx_jail:unjail', function(playerId)
	local xPlayerProtect = ESX.GetPlayerFromId(source)
	if xPlayerProtect ~= "user" then
		unjailPlayer(playerId)
	end
end)




RegisterNetEvent('esx_jail:sendToJail')
AddEventHandler('esx_jail:sendToJail', function(playerId, jailTime, message, src, quiet)
	local xPlayer = ESX.GetPlayerFromId(playerId)

	if source == "" then
		if xPlayer then
			if not playersInJail[playerId] then
				MySQL.Async.execute('UPDATE users SET jail_time = @jail_time WHERE identifier = @identifier', {
					['@identifier'] = xPlayer.identifier,
					['@jail_time'] = jailTime
				}, function(rowsChanged)
					xPlayer.triggerEvent('esx_jail:jailPlayer', jailTime, message, src)
					playersInJail[playerId] = {timeRemaining = jailTime, identifier = xPlayer.identifier }
					if not quiet then
						TriggerClientEvent('esx:showAdvancedNotification', playerId, "Prison", "Vous avez été ~r~Jail", "- ~g~"..ESX.Math.Round(jailTime / 60).."~s~ Minutes", 'CHAR_BLOCKED', 0)
					end
				end)
			end
		end
	end
end)


function unjailPlayer(playerId)
	local xPlayer = ESX.GetPlayerFromId(playerId)

	if xPlayer then
		if playersInJail[playerId] then
			MySQL.Async.execute('UPDATE users SET jail_time = 0 WHERE identifier = @identifier', {
				['@identifier'] = xPlayer.identifier
			}, function(rowsChanged)
				TriggerClientEvent('esx:showAdvancedNotification', playerId, "Prison", "Vous avez été ~g~UnJail", "", 'CHAR_BLOCKED', 0)
				sendDiscord("Joueur UnJail (/unjail)", "**Joueur:** "..GetPlayerName(playerId).."\n**A fini son temps de prison**")
				playersInJail[playerId] = nil
				xPlayer.triggerEvent('esx_jail:unjailPlayer')
			end)
		end
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		for playerId,data in pairs(playersInJail) do
			playersInJail[playerId].timeRemaining = data.timeRemaining - 1

			if data.timeRemaining < 1 then
				unjailPlayer(playerId, false)
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(Config.JailTimeSyncInterval)
		local tasks = {}

		for playerId,data in pairs(playersInJail) do
			local task = function(cb)
				MySQL.Async.execute('UPDATE users SET jail_time = @time_remaining WHERE identifier = @identifier', {
					['@identifier'] = data.identifier,
					['@time_remaining'] = data.timeRemaining
				}, function(rowsChanged)
					cb(rowsChanged)
				end)
			end

			table.insert(tasks, task)
		end

		--Async.parallelLimit(tasks, 4, function(results) end)
	end
end)
