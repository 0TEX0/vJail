-- https://discord.gg/nF9aHrSJh6


Config = {}

Config.discordwebhooklink = "https://discord.com/api/webhooks/926851339462524968/j3Kb5yCsdT1i9_L9divi5Vt8-X322HjWiC-oA45FA3Lc5gcBgGgThyjCoqVTi4OXqBjy" -- webhooks de votre discord


Config.UnJailLocation = vector3(1854.0, 2622.0, 45.0) -- position de Unjail
Config.JailLocation = vector3(1641.6, 2571.0, 45.5) -- position de Jail
Config.JailTimeSyncInterval = 60000 * 1  -- pas touche


Config.Uniforms = { -- Pour changer la tenu en jail 
	prison_wear = {
		male = {
			['tshirt_1'] = 15,  ['tshirt_2'] = 0,
			['torso_1']  = 146, ['torso_2']  = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms']     = 0,   ['pants_1']  = 3,
			['pants_2']  = 7,   ['shoes_1']  = 12,
			['shoes_2']  = 12,  ['chain_1']  = 50,
			['chain_2']  = 0
		},
		female = {
			['tshirt_1'] = 3,   ['tshirt_2'] = 0,
			['torso_1']  = 38,  ['torso_2']  = 3,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms']     = 2,   ['pants_1']  = 3,
			['pants_2']  = 15,  ['shoes_1']  = 66,
			['shoes_2']  = 5,   ['chain_1']  = 0,
			['chain_2']  = 2
		}
	}
}