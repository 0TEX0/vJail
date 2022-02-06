local isInJail, unjail = false, false
local jailTime, fastTimer = 0, 0
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('OTEXO&KraKss:esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(500)
	end
end)

local xPlayer = PlayerPedId(-1)
local ped = GetPlayerPed(PlayerPedId())


local mainMenu = RageUI.CreateMenu("~r~Jail", "~r~Vous avez été Jail") -- Création du menu principale
mainMenu.Closable = false;
mainMenu.Closed = function()
    touche = false
end


RegisterNetEvent('esx_jail:jailPlayer')
AddEventHandler('esx_jail:jailPlayer', function(_jailTime, message, src)
	jailTime = _jailTime
	msg = message
	lol = src
	local playerPed = PlayerPedId()


	TriggerEvent('skinchanger:getSkin', function(skin)
		if skin.sex == 0 then
			TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.prison_wear.male)
		else
			TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.prison_wear.female)
		end
	end)

	SetPedArmour(playerPed, 0)
	ESX.Game.Teleport(playerPed, Config.JailLocation)
	isInJail, unjail = true, false


	touche = true 
		RageUI.Visible(mainMenu, true)
		CreateThread(function()
			while touche do 

				if jailTime > 0 and isInJail then
					if fastTimer < 0 then
						fastTimer = jailTime 
					end

					fastTimer = fastTimer - 0.007666666 --pas touche

					RageUI.IsVisible(mainMenu, function()
						RageUI.Button("Auteur du jail :", nil, {RightLabel = lol}, true, {}) -- Button affiché dans le menu
						RageUI.Button("Temps", nil, {RightLabel = ESX.Math.Round(jailTime / 60).." Minutes"}, true, {}) -- Button affiché dans le menu
						RageUI.Line(0,0,0,250)
						RageUI.Button("Temps restant :", nil, {RightLabel = ESX.Math.Round(fastTimer).." Secondes"}, true, {}) -- Button affiché dans le menu
						if message == true then
							RageUI.Separator("~r~Tu t'es déconnecter")
						else
							RageUI.Button("Raison de Votre Jail :", nil, {RightLabel = msg }, true, {}) -- Button affiché dans le menu
						end
					end)
				else
				end
				Wait(0)


				DisableControlAction(2, 37, true) -- Select Weapon
				DisableControlAction(0, 25, true) -- Input Aim
				DisableControlAction(0, 24, true) -- Input Attack
				DisableControlAction(0, 257, true) -- Disable melee
				DisableControlAction(0, 140, true) -- Disable melee
				DisableControlAction(0, 142, true) -- Disable melee
				DisableControlAction(0, 143, true) -- Disable melee
			end
	end)



	while not unjail do
		playerPed = PlayerPedId()

		--RemoveAllPedWeapons(playerPed, true)
		if IsPedInAnyVehicle(playerPed, false) then
			ClearPedTasksImmediately(playerPed)
		end

		Citizen.Wait(0)

		-- Is the player trying to escape?
		if #(GetEntityCoords(playerPed) - Config.JailLocation) > 10 then
			ESX.Game.Teleport(playerPed, Config.JailLocation)
		end
	end

	ESX.Game.Teleport(playerPed, Config.UnJailLocation)
	isInJail = false

	RageUI.CloseAll() --retire le menu
    touche = false

	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
		TriggerEvent('skinchanger:loadSkin', skin)
	end)
end)


RegisterNetEvent('esx_jail:unjailPlayer')
AddEventHandler('esx_jail:unjailPlayer', function()
	unjail, jailTime, fastTimer = true, 0, 0
end)

AddEventHandler('playerSpawned', function(spawn)
	if isInJail then
		ESX.Game.Teleport(PlayerPedId(), Config.JailLocation)
	end
end)


